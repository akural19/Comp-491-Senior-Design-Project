from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Video
from .ml.ml_utils import VideoProcessor

@receiver(post_save, sender=Video)
def process_video_signal(sender, instance, created, **kwargs):
    if created:
        processor = VideoProcessor(instance)
        processor.start()