from django.urls import path, include
from .views import create_cabin, get_cabins, update_cabin, delete_cabin
from .views import create_area, get_areas, update_area, delete_area

urlpatterns = [
    path("create", create_area),
    path("update", update_area),
    path("delete", delete_area),
    path("", get_areas),
    path("cabins/create", create_cabin),
    path("cabins/update", update_cabin),
    path("cabins/delete", delete_cabin),
    path("cabins", get_cabins),
    path("services/", include("services.urls")),
]
