from django.urls import path
from .views import create_service, get_service, update_service, delete_service

urlpatterns = [
    path("create", create_service),
    path("get", get_service),
    path("update", update_service),
    path("delete", delete_service),
    path("create_service", create_service, name='create_service')
]
