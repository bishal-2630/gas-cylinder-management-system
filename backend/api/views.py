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
    permission_classes = [permissions.IsAuthenticatedOrReadOnly] # Allow read, require auth to update

    def perform_update(self, serializer):
        # In a real app, ensure self.request.user.dealer_profile == serializer.instance.dealer
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
            # Create a placeholder dealer profile. The dealer can update name/location later.
            Dealer.objects.create(
                user=user, 
                name=username, 
                latitude=27.7172, 
                longitude=85.3240 # Default to Kathmandu center
            )
        
        return Response({'message': 'User created successfully'}, status=status.HTTP_201_CREATED)
