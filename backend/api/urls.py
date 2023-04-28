from django.urls import path, include

urlpatterns = [
    path("user/", include("users.urls")),
    path("area/", include("cabins.urls")),
    path("reservation/", include("reservations.urls")),
    path("service/", include("services.urls")),
]
