from django.urls import include, path

urlpatterns = [
    path('', include('game_site.urls')),
]
