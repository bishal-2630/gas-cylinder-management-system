from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import DealerViewSet, OfficialStockViewSet, CommunitySightingViewSet, ProfileViewSet, QueueTokenViewSet

router = DefaultRouter()
router.register(r'dealers', DealerViewSet)
router.register(r'stock', OfficialStockViewSet)
router.register(r'sightings', CommunitySightingViewSet)
router.register(r'profile', ProfileViewSet, basename='profile')
router.register(r'tokens', QueueTokenViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
