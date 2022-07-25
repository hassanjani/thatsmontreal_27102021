class MDAnnouncementGallery{
  int id=-1;
  String announcement_id="-1";
  String path = "assets/product.png";

  MDAnnouncementGallery(String imagePath){
    this.id = -1;
    this.announcement_id = '-1';
    this.path = imagePath;
  }

  MDAnnouncementGallery.fromJson(Map json):
      id = json['id'] == null ? 0 : json['id'],
        announcement_id = json['announcement_id'] == null ? '0' : json['announcement_id'],
        path = json['path'] == null ? '' : json['path'];
}