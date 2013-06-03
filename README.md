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

[yaml install][0]
[ruby & rails][1]  
[update rails mirror in China][2]
[0]: http://collectiveidea.com/blog/archives/2011/10/31/install-ruby-193-with-libyaml-on-centos/
[1]: http://ruby-china.org/wiki/install_ruby_guide
[2]: http://ruby.taobao.org/

[ffmpeg install on Ubuntu] [3]  
[ffmpeg install on CentOS] [4]
[3]: https://ffmpeg.org/trac/ffmpeg/wiki/UbuntuCompilationGuide
[4]: http://ffmpeg.org/trac/ffmpeg/wiki/CentosCompilationGuide

You can also refer the script/ffmpeg_install.sh to install ffmpeg

[torque install] [5]  
[torque configuration][6]
[5]: http://www.clusterresources.com/torquedocs21/1.1installation.shtml
[6]: http://www.clusterresources.com/torquedocs21/1.2basicconfig.shtml

FUNCTION
--

1. Upload media files
2. Convert the media files to certain format
3. Download the media files which have been converted

CONFIGURATION
--

1. Update the database configuration in config/database.yml
2. Update the userdefined information in config/vtrans.yml, e.g. pbs_job_queue, trans_cmd, server_path, upload_path, trans_path

USAGE
--

### Torque configuration example

    $ cat /var/spool/torque/mom_priv/config
    $pbsserver  localhost   # note: hostname running pbs_server
    $logevent   255         # bitmap of which events to log

    $ cat /var/spool/torque/server_priv/nodes
    localhost np=2 cluster01
    
    $ cat /var/spool/torque/server_name
    localhost

    # start pbs
    $ script/torque.setup vtrans localhost # root cannot submit PBS job

    OR 

    $ qterm -t quick
    $ pbs_mom
    $ pbs_server
    $ pbs_sched

    # check the pbs
    $ pbsnodes -a
    localhost
     state = free
     np = 2
     properties = cluster01
     ntype = cluster
     status = rectime=1370243700,varattr=,jobs=,state=free,netload=551237319,gres=,loadave=0.43,ncpus=4,physmem=3961760kb,availmem=9139208kb,totmem=12149660kb,idletime=1703,nusers=4,nsessions=13,sessions=1000 1200 2082 2123 2163 2222 3317 13271 13316 14107 14958 1099 24267,uname=Linux liangfan 3.2.0-37-generic #58-Ubuntu SMP Thu Jan 24 15:28:10 UTC 2013 x86_64,opsys=linux
     mom_service_port = 15002
     mom_manager_port = 15003
     gpus = 0    


### Development mode

In the VTrans root directory, execute `sudo bundle install`
 
Build datatbase: 

    $ rake db:create
    $ rake db:migrate
              
To run thin server, execute `rails server thin`

### Production mode
