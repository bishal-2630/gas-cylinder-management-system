from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from django.contrib.auth.models import User
from core.models import Dealer, OfficialStock, CommunitySighting, UserProfile
from .serializers import (
    DealerSerializer, OfficialStockSerializer, 
    CommunitySightingSerializer, UserSerializer
)

class DealerViewSet(viewsets.ModelViewSet):
    """
    List all dealers or create a new community report.
    """
    queryset = Dealer.objects.all()
    serializer_class = DealerSerializer
    permission_classes = [permissions.AllowAny]

class IsDealerOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        # Check for OfficialStock (obj.dealer) or Dealer (obj)
        dealer = obj.dealer if hasattr(obj, 'dealer') else obj
        return dealer.user == request.user

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
        full_name = request.data.get('full_name')
        phone_number = request.data.get('phone_number')
        password = request.data.get('password')
        role = request.data.get('role')

        if not username or not full_name or not phone_number or not password or not role:
            return Response({'error': 'Missing required fields'}, status=status.HTTP_400_BAD_REQUEST)

        if User.objects.filter(username=username).exists():
            return Response({'error': 'Username already exists'}, status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.create_user(username=username, password=password)
        UserProfile.objects.create(
            user=user, 
            role=role, 
            full_name=full_name, 
            phone_number=phone_number
        )
        
        if role == 'DEALER':
            dealer = Dealer.objects.create(
                user=user, 
                name=full_name, 
                latitude=27.7172, 
                longitude=85.3240,
                phone_number=phone_number
            )
            OfficialStock.objects.create(dealer=dealer)
        
        return Response({'message': 'User created successfully'}, status=status.HTTP_201_CREATED)

from core.models import QueueToken
from .serializers import QueueTokenSerializer
from django.utils import timezone


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
