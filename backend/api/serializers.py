from rest_framework import serializers
from django.contrib.auth.models import User
from core.models import Brand, Dealer, OfficialStock, CommunitySighting, UserProfile

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ['role', 'full_name', 'phone_number']

class UserSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(read_only=True)
    dealer_profile_id = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['id', 'username', 'profile', 'dealer_profile_id']

    def get_dealer_profile_id(self, obj):
        if hasattr(obj, 'dealer_profile'):
            return obj.dealer_profile.id
        return None

class DealerSerializer(serializers.ModelSerializer):
    brand_name = serializers.CharField(source='get_brand_display', read_only=True)

    class Meta:
        model = Dealer
        fields = ['id', 'name', 'brand', 'brand_name', 'latitude', 'longitude', 'address', 'phone_number', 'is_verified', 'availability_status']

class OfficialStockSerializer(serializers.ModelSerializer):
    dealer = DealerSerializer(read_only=True)

    class Meta:
        model = OfficialStock
        fields = ['id', 'dealer', 'full_cylinders', 'empty_cylinders', 'last_updated']

class CommunitySightingSerializer(serializers.ModelSerializer):
    dealer_id = serializers.PrimaryKeyRelatedField(
        queryset=Dealer.objects.all(), source='dealer', write_only=True
    )
    dealer = DealerSerializer(read_only=True)
    reporter_name = serializers.CharField(source='reporter.username', read_only=True)

    class Meta:
        model = CommunitySighting
        fields = ['id', 'dealer_id', 'dealer', 'reporter_name', 'reported_at', 'is_available', 'notes']

from core.models import QueueToken

class QueueTokenSerializer(serializers.ModelSerializer):
    dealer_id = serializers.PrimaryKeyRelatedField(
        queryset=Dealer.objects.all(), source='dealer', write_only=True
    )
    dealer_name = serializers.CharField(source='dealer.name', read_only=True)
    user_name = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = QueueToken
        fields = ['id', 'dealer_id', 'dealer_name', 'user_name', 'token_number', 'requested_at', 'is_fulfilled', 'fulfilled_at']
        read_only_fields = ['token_number', 'requested_at', 'is_fulfilled', 'fulfilled_at']
