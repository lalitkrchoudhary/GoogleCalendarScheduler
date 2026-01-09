from django.contrib import admin
from .models import Availability


@admin.register(Availability)
class AvailabilityAdmin(admin.ModelAdmin):
    list_display = ['admin', 'date', 'start_time', 'end_time', 'slot_duration', 'is_active', 'created_at']
    list_filter = ['is_active', 'date', 'admin']
    search_fields = ['admin__username', 'admin__email']
    date_hierarchy = 'date'
    list_editable = ['is_active']
    
    def get_queryset(self, request):
        qs = super().get_queryset(request)
        if request.user.is_super_admin():
            return qs
        elif request.user.is_admin_role():
            return qs.filter(admin=request.user)
        return qs.none()
