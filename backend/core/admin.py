from django.contrib import admin
from .models import Dealer, OfficialStock, CommunitySighting

@admin.register(Dealer)
class DealerAdmin(admin.ModelAdmin):
    list_display = ('name', 'brand', 'is_verified', 'availability_status')
    list_filter = ('brand', 'is_verified')
    search_fields = ('name', 'address')

@admin.register(OfficialStock)
class OfficialStockAdmin(admin.ModelAdmin):
    list_display = ('dealer', 'full_cylinders', 'empty_cylinders', 'last_updated')
    list_filter = ('dealer__brand',)

@admin.register(CommunitySighting)
class CommunitySightingAdmin(admin.ModelAdmin):
    list_display = ('dealer', 'is_available', 'reported_at', 'reporter')
    list_filter = ('is_available', 'reported_at')
