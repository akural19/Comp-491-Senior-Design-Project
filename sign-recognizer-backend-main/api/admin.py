from django.contrib import admin
from .models import Video

@admin.register(Video)
class VideoAdmin(admin.ModelAdmin):
    list_display = ('id', 'video_file', 'status', 'result', 'uploaded_at')
    list_filter = ('status', 'uploaded_at')
    search_fields = ('id', 'result')
    readonly_fields = ('uploaded_at', 'status', 'result')
    ordering = ('-uploaded_at',)

    def has_add_permission(self, request):
        return True

    def has_change_permission(self, request, obj=None):
        return True

    def has_delete_permission(self, request, obj=None):
        return True

    def get_readonly_fields(self, request, obj=None):
        if obj:  # Düzenleme durumunda
            return self.readonly_fields
        return ()  # Yeni oluşturma durumunda

admin.site.site_header = "Sign Recognizer Admin"
admin.site.site_title = "Sign Recognizer Admin Portal"
admin.site.index_title = "Welcome to Sign Recognizer Admin Portal"