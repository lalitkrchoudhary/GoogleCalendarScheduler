from django.contrib import admin
from .models import Booking


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ['user', 'admin', 'date', 'start_time', 'end_time', 'status', 'created_at']
    list_filter = ['status', 'date', 'admin']
    search_fields = ['user__username', 'admin__username', 'meeting_purpose']
    date_hierarchy = 'date'
    list_editable = ['status']
    readonly_fields = ['calendar_event_id', 'created_at', 'updated_at']
    
    fieldsets = (
        ('Booking Information', {
            'fields': ('user', 'admin', 'date', 'start_time', 'end_time', 'timezone', 'status')
        }),
        ('Meeting Details', {
            'fields': ('meeting_purpose', 'meeting_link', 'notes')
        }),
        ('Integration', {
            'fields': ('calendar_event_id',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )
    
    def get_queryset(self, request):
        qs = super().get_queryset(request)
        if request.user.is_super_admin():
            return qs
        elif request.user.is_admin_role():
            return qs.filter(admin=request.user)
        return qs.filter(user=request.user)
