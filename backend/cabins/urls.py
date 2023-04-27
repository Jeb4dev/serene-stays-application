from django.urls import path, include
from .views import create_cabin, create_area

urlpatterns = [
    path("create", create_area),
    path("cabins/create", create_cabin),
    path("services/", include("services.urls")),
]
