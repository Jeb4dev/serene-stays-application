from django.urls import path, include
from .views import create_cabin, create_area, get_cabins

urlpatterns = [
    path("create", create_area),
    path("cabins/create", create_cabin),
    path("cabins", get_cabins),
    path("services/", include("services.urls")),
]
