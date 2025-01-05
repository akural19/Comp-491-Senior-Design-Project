from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Video
from .serializers import VideoSerializer
from .ml.ml_utils import VideoProcessor
import logging

logger = logging.getLogger(__name__)

class VideoUploadView(APIView):
    def post(self, request):
        if 'video' not in request.FILES:
            return Response(
                {'error': 'No video file provided'},
                status=status.HTTP_400_BAD_REQUEST
            )
            
        try:
            video_file = request.FILES['video']
            if not video_file.content_type.startswith('video/'):
                return Response(
                    {'error': 'Invalid file type. Please upload a video file.'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            # Video nesnesini oluştur
            video = Video.objects.create(
                video_file=video_file,
                status='pending'
            )
            
            try:
                # Video işleme işlemini başlat
                processor = VideoProcessor(video)
                processor.start()
                logger.info(f"Started processing for video: {video.id}")
            except Exception as e:
                logger.error(f"Error starting processor: {e}")
                video.status = 'failed'
                video.result = f"Failed to start processing: {str(e)}"
                video.save()
                raise

            serializer = VideoSerializer(video)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
            
        except Exception as e:
            logger.error(f"Error in video upload: {str(e)}")
            return Response(
                {'error': f'Error processing video: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class VideoStatusView(APIView):
    def get(self, request, video_id):
        try:
            video = Video.objects.get(id=video_id)
            serializer = VideoSerializer(video)
            
            response_data = {
                'id': video.id,
                'status': video.status,
                'result': video.result if video.result else None,
                'uploaded_at': video.uploaded_at
            }
            
            if video.status == 'completed':
                return Response(response_data)
            elif video.status == 'failed':
                return Response(
                    response_data,
                    status=status.HTTP_422_UNPROCESSABLE_ENTITY
                )
            else:
                return Response(response_data)
                
        except Video.DoesNotExist:
            return Response(
                {'error': 'Video not found'}, 
                status=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            logger.error(f"Error in video status check: {str(e)}")
            return Response(
                {'error': f'Error checking video status: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )