from django.urls import path
from .views import register, login, logout, get_data, update_data, delete_data

urlpatterns = [
    path("register", register),
    path("login", login),
    path("logout", logout),
    path("", get_data),
    path("update", update_data),
    path("delete", delete_data),
]
