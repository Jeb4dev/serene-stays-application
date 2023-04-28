from django.urls import path, include

urlpatterns = [
    path("user/", include("users.urls")),
    path("area/", include("cabins.urls")),
]
