class Admin::AnnouncementsController < AdminController
  def index
    @announcements = Announcement.all.page(params[:page]).per(50)
  end

  def show
    @announcement = Announcement.find(params[:id])
  end

  def new
    event = Event.find_by!(slug: Event::ONGOING_EVENT_SLUG)
    @announcement = Announcement.new(event: event)
  end

  def create
    Announcement.create!(**announcement_params)
    redirect_to admin_announcements_path
  end

  def edit
    @announcement = Announcement.find(params[:id])
  end

  def update
    announcement = Announcement.find(params[:id])
    if announcement.update(**announcement_params)
      flash.now[:success] = "Update succeeded"
      if announcement.previous_changes.has_key?("status") && announcement.previous_changes["status"] == ["draft", "published"]
        BroadcastAnnouncementJob.perform_later(announcement.id)
      end
      redirect_to admin_announcement_path(announcement)
    else
      flash.now[:alert] = "Update failed"
      redirect_to edit_admin_announcement_path(announcement)
    end
  end

  private def announcement_params
    params.require(:announcement).permit(:event_id, :title, :content, :status)
  end
end