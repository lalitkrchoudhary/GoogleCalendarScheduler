from django.urls import path
from .views import (
    AvailabilityListCreateView,
    AvailabilityDetailView,
    AvailableTimeSlotsView
)

app_name = 'availability'

urlpatterns = [
    path('', AvailabilityListCreateView.as_view(), name='availability-list'),
    path('<int:pk>/', AvailabilityDetailView.as_view(), name='availability-detail'),
    path('slots/', AvailableTimeSlotsView.as_view(), name='available-slots'),
]
