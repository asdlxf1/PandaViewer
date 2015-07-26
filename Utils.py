import os
from Logger import Logger

class Utils(Logger):

    @classmethod
    def path_exists_under_directory(cls, main_directory, sub_directory):
        main_directory = cls.normalize_path(main_directory)
        sub_directory = cls.normalize_path(sub_directory)
        return main_directory in sub_directory

    @classmethod
    def file_has_allowed_extension(cls, check_file, allowed_extensions):
        ext = os.path.splitext(check_file)[-1].lower()
        return ext in allowed_extensions

    @classmethod
    def normalize_path(cls, path):
        return os.path.normpath(os.path.realpath(path))

    @classmethod
    def get_readable_size(cls, num,  suffix="B"):
        for unit in ["", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi"]:
            if abs(num) < 1024.0:
                return "%3.1f%s%s" % (num, unit, suffix)
            num /= 1024.0
        return "%.1f%s%s" % (num, "Yi", suffix)

    @classmethod
    def reduce_gallery_duplicates(cls, duplicate_map):
        cls = cls()
        for galleries in duplicate_map.values():
            paths = [cls.normalize_path(gallery.location) for gallery in galleries]
            try:
                assert len(paths) == len(set(paths))
            except AssertionError:
                cls.logger.error("Galleries: %s" % galleries)
                cls.logger.error("Paths: %s" % len(paths))
                cls.logger.error("Set: %s" % len(set(paths)))
                cls.logger.error("Bad: %s" % [p for p in paths if p not in list(set(paths))])
                raise
            method_names = ["has_ex_metadata", "has_custom_metadata", "is_archive_gallery"]
            for method_name in method_names:
                if any(getattr(gallery, method_name)() for gallery in galleries):
                    cls.logger.info("Applying method: %s" % method_name)
                    cls.logger.debug("Before galleries: %s" % galleries)
                    filtered_galleries = []
                    for gallery in galleries:
                        if not getattr(gallery, method_name)():
                            gallery.mark_for_deletion()
                        else:
                            filtered_galleries.append(gallery)
                    galleries = filtered_galleries
                    cls.logger.debug("After galleries: %s" % galleries)
            for gallery in galleries[1:]:
                gallery.mark_for_deletion()