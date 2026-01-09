from django.urls import path
from .views import (
    BookingListCreateView, BookingDetailView,
    CancelBookingView, RescheduleBookingView,
    UserDashboardView, AdminDashboardView
)

app_name = 'bookings'

urlpatterns = [
    # Booking CRUD
    path('', BookingListCreateView.as_view(), name='booking-list'),
    path('<int:pk>/', BookingDetailView.as_view(), name='booking-detail'),
    path('<int:pk>/cancel/', CancelBookingView.as_view(), name='booking-cancel'),
    path('<int:pk>/reschedule/', RescheduleBookingView.as_view(), name='booking-reschedule'),
    
    # Dashboards
    path('dashboard/user/', UserDashboardView.as_view(), name='user-dashboard'),
    path('dashboard/admin/', AdminDashboardView.as_view(), name='admin-dashboard'),
]
