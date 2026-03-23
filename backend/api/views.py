from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from django.contrib.auth.models import User
from core.models import Dealer, OfficialStock, CommunitySighting, UserProfile
from .serializers import (
    DealerSerializer, OfficialStockSerializer, 
    CommunitySightingSerializer, UserSerializer
)

class DealerViewSet(viewsets.ReadOnlyModelViewSet):
    """
    List all dealers or retrieve a specific dealer.
    Read-only for now; admin users manage dealers via Django Admin.
    """
    queryset = Dealer.objects.all()
    serializer_class = DealerSerializer

class OfficialStockViewSet(viewsets.ModelViewSet):
    """
    List and update official stock.
    Normally, this would require specific dealer permissions.
    """
    queryset = OfficialStock.objects.all()
    serializer_class = OfficialStockSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsDealerOwner]

    def perform_update(self, serializer):
        serializer.save()

class CommunitySightingViewSet(viewsets.ModelViewSet):
    """
    List all sightings or create a new community report.
    """
    queryset = CommunitySighting.objects.all().order_by('-reported_at')
    serializer_class = CommunitySightingSerializer
    permission_classes = [permissions.AllowAny] # Allow anyone to report for now

    def perform_create(self, serializer):
        # If user is logged in, attach them to the report
        if self.request.user.is_authenticated:
            serializer.save(reporter=self.request.user)
        else:
            serializer.save()

class ProfileViewSet(viewsets.ViewSet):
    """
    Get current user profile.
    """
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=['get'])
    def me(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

    @action(detail=False, methods=['post'], permission_classes=[permissions.AllowAny])
    def signup(self, request):
        username = request.data.get('username')
        email = request.data.get('email')
        password = request.data.get('password')
        role = request.data.get('role')

        if not username or not password or not role:
            return Response({'error': 'Missing fields'}, status=status.HTTP_400_BAD_REQUEST)

        if User.objects.filter(username=username).exists():
            return Response({'error': 'Username already exists'}, status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.create_user(username=username, email=email, password=password)
        UserProfile.objects.create(user=user, role=role)
        
        if role == 'DEALER':
            dealer = Dealer.objects.create(
                user=user, 
                name=username, 
                latitude=27.7172, 
                longitude=85.3240
            )
            OfficialStock.objects.create(dealer=dealer)
        
        return Response({'message': 'User created successfully'}, status=status.HTTP_201_CREATED)

from core.models import QueueToken
from .serializers import QueueTokenSerializer
from django.utils import timezone

class IsDealerOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        # Check for OfficialStock (obj.dealer) or Dealer (obj)
        dealer = obj.dealer if hasattr(obj, 'dealer') else obj
        return dealer.user == request.user

class QueueTokenViewSet(viewsets.ModelViewSet):
    queryset = QueueToken.objects.all()
    serializer_class = QueueTokenSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        dealer = serializer.validated_data['dealer']
        next_number = QueueToken.objects.filter(dealer=dealer).count() + 1
        serializer.save(user=self.request.user, token_number=next_number)

    @action(detail=True, methods=['post'])
    def fulfill(self, request, pk=None):
        token = self.get_object()
        if token.dealer.user != request.user:
            return Response({'error': 'Unauthorized'}, status=status.HTTP_401_UNAUTHORIZED)
        token.is_fulfilled = True
        token.fulfilled_at = timezone.now()
        token.save()
        return Response({'status': 'token fulfilled'})
