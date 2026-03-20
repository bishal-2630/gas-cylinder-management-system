from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import DealerViewSet, OfficialStockViewSet, CommunitySightingViewSet, ProfileViewSet

router = DefaultRouter()
router.register(r'dealers', DealerViewSet)
router.register(r'stock', OfficialStockViewSet)
router.register(r'sightings', CommunitySightingViewSet)
router.register(r'profile', ProfileViewSet, basename='profile')

urlpatterns = [
    path('', include(router.urls)),
]
