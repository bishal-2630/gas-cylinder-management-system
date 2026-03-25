from django.db import models
from django.contrib.auth.models import User

class UserProfile(models.Model):
    CUSTOMER = 'CUSTOMER'
    DEALER = 'DEALER'
    ROLE_CHOICES = [
        (CUSTOMER, 'Customer'),
        (DEALER, 'Dealer'),
    ]
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default=CUSTOMER)
    full_name = models.CharField(max_length=255, blank=True)
    phone_number = models.CharField(max_length=15, blank=True)

    def __str__(self):
        return f"{self.user.username} - {self.role}"

class Brand(models.fields.CharField):
    # Enum for gas brands in Nepal
    NEPAL_GAS = 'NEPAL_GAS'
    EVEREST = 'EVEREST'
    SIDDHARTHA = 'SIDDHARTHA'
    CHOICES = [
        (NEPAL_GAS, 'Nepal Gas'),
        (EVEREST, 'Everest Gas'),
        (SIDDHARTHA, 'Siddhartha Gas'),
    ]

# We might want to use GeoDjango's PointField if dealing with real coordinates, 
# but starting with simple Lat/Lon floats for easier initial setup without PostGIS dependencies.
class Dealer(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='dealer_profile')
    name = models.CharField(max_length=255)
    brand = models.CharField(max_length=50, choices=Brand.CHOICES, default=Brand.NEPAL_GAS)
    latitude = models.FloatField()
    longitude = models.FloatField()
    address = models.TextField(blank=True)
    phone_number = models.CharField(max_length=15, blank=True)
    is_verified = models.BooleanField(default=False)
    
    @property
    def availability_status(self):
        # Logic to aggregate stock and sightings
        from django.utils import timezone
        from datetime import timedelta
        
        # Check official stock first
        if hasattr(self, 'current_stock') and self.current_stock.full_cylinders > 0:
            return 'OFFICIAL_AVAILABLE'
            
        # Check sightings in last 24 hours
        recent_cutoff = timezone.now() - timedelta(hours=24)
        positive_sightings = self.sightings.filter(is_available=True, reported_at__gte=recent_cutoff).count()
        
        if positive_sightings >= 3:
            return 'COMMUNITY_CONFIRMED'
        elif positive_sightings > 0:
            return 'COMMUNITY_REPORTED'
            
        return 'OUT_OF_STOCK'

    def __str__(self):
        return f"{self.name} ({self.get_brand_display()})"

class OfficialStock(models.Model):
    dealer = models.OneToOneField(Dealer, on_delete=models.CASCADE, related_name='current_stock')
    full_cylinders = models.PositiveIntegerField(default=0)
    empty_cylinders = models.PositiveIntegerField(default=0)
    last_updated = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Stock for {self.dealer.name}"

class CommunitySighting(models.Model):
    # Optional relation if users need accounts to report, otherwise anonymous
    reporter = models.ForeignKey(User, null=True, blank=True, on_delete=models.SET_NULL)
    dealer = models.ForeignKey(Dealer, related_name='sightings', on_delete=models.CASCADE)
    reported_at = models.DateTimeField(auto_now_add=True)
    is_available = models.BooleanField(default=True)
    notes = models.TextField(blank=True, help_text="e.g., Long queue, limited stock")
    
    def __str__(self):
        status = "Available" if self.is_available else "Out of Stock"
        return f"Sighting at {self.dealer.name}: {status} on {self.reported_at.date()}"

class QueueToken(models.Model):
    dealer = models.ForeignKey(Dealer, related_name='tokens', on_delete=models.CASCADE)
    user = models.ForeignKey(User, related_name='tokens_requested', on_delete=models.CASCADE)
    token_number = models.PositiveIntegerField()
    requested_at = models.DateTimeField(auto_now_add=True)
    is_fulfilled = models.BooleanField(default=False)
    fulfilled_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        unique_together = ['dealer', 'token_number']
        ordering = ['token_number']

    def __str__(self):
        return f"Token #{self.token_number} at {self.dealer.name} for {self.user.username}"
