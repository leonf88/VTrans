VTrans
==

A web framework for converting a video in remote servers. Web server is based on ruby and rails. Video converting is based on ffmpeg. Multiple converting job management is based on Torque.

Licensed under the GNU Lesser General Public License Copyright (c) 2012-2013

Version 0.1.0 build 20130603

REQUIRE
--

According to my development environment, VTrans project require these software below:

> Ubuntu 12.0.4 or CentOS 5  
> ruby 1.9.3p429  
> rails 3.2.13  
> ffmpeg 1.2.1  
> torque 3.0.6  
> mysql  

INSTALL
--

[ruby & rails][1]  
[update rails mirror in China][2]
[1]: http://ruby-china.org/wiki/install_ruby_guide
[2]: http://ruby.taobao.org/

[ffmpeg install on Ubuntu] [3]  
[ffmpeg install on CentOS] [4]
[3]: https://ffmpeg.org/trac/ffmpeg/wiki/UbuntuCompilationGuide
[4]: http://ffmpeg.org/trac/ffmpeg/wiki/CentosCompilationGuide

[torque install] [5]  
[torque configuration][6]
[5]: http://www.clusterresources.com/torquedocs21/1.1installation.shtml
[6]:http://www.clusterresources.com/torquedocs21/1.2basicconfig.shtml

FUNCTION
--

1. Upload media files
2. Convert the media files to certain format
3. Download the media files which have been converted

CONFIGURATION
--

1. Update the database configuration in config/database.yml
2. Update the userdefined information in config/vtrans.yml, e.g. pbs_job_queue, trans_cmd, server_path, upload_path, trans_path
