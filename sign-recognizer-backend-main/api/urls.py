from django.urls import path
from .views import VideoUploadView, VideoStatusView

urlpatterns = [
    path('upload/', VideoUploadView.as_view(), name='video-upload'),
    path('status/<int:video_id>/', VideoStatusView.as_view(), name='video-status'),
]