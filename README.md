VTrans
==

A web framework for converting a video in remote servers. Web server is based on ruby and rails. Video converting is based on ffmpeg. Multiple converting job management is based on Torque.

Licensed under the GNU Lesser General Public License Copyright (c) 2012-2013

Version 0.2.0 build 20151218

REQUIRE
--

According to my development environment, VTrans project require these software below:

> CentOS 6  
> ruby 1.9.3p429  
> rails 3.2.13  
> ffmpeg 2.8.4  
> torque 4.2.10 
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
     status = rectime=1370243700,varattr=,jobs=,state=free,netload=551237319,gres=,loadave=0.43,ncpus=4,
        physmem=3961760kb,availmem=9139208kb,totmem=12149660kb,idletime=1703,nusers=4,nsessions=13,
        sessions=1000 1200 2082 2123 2163 2222 3317 13271 13316 14107 14958 1099 24267,
        uname=Linux liangfan 3.2.0-37-generic #58-Ubuntu SMP Thu Jan 24 15:28:10 UTC 2013 x86_64,opsys=linux
     mom_service_port = 15002
     mom_manager_port = 15003
     gpus = 0    


### Development mode

In the VTrans root directory, execute `sudo bundle install`
 
Build datatbase: 

    $ rake db:create
    $ rake db:migrate
              
To run thin server, execute `rails server thin`

STEP BY STEP
--

1. create user with `root`
    
        $ useradd vtrans
        $ passwd vtrans (passwd is vtrans)
        $ visudo (add one line `vtrans  ALL=(ALL)       ALL`)

2. install mysql on dashboard node (such as node1)

        $ mysql -uroot -p
        
        > CREATE USER 'vtrans'@'localhost' IDENTIFIED BY '123456';
        > GRANT ALL PRIVILEGES ON * . * TO 'vtrans'@'localhost';
        > flush privileges;

3. install rvm and ruby 

    install rvm

        $ gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
        $ \curl -sSL https://get.rvm.io | bash -s stable
        $ source ~/.profile (as the WARNING states)

    Check the `cat ~/.profile` file

        export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

        [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

    after that, install ruby 1.9.3 

        $ rvm install 1.9.3
        $ rvm use 1.9.3
        $ gem source -r https://rubygems.org/
        $ gem source -a https://ruby.taobao.org

4. install VTrans

        $ git clone https://github.com/liangfan/VTrans
        $ cd VTrans
        $ gem install bundle
        $ bundle install
        $ rake db:create 
        $ rake db:migrate

    When create database, check the sock is correct. In `/etc/my.cnf`, 
    the sock path should be the same with that in `config/database.yml`.

    Prepare the paths which are defined in `config/vtrans.yml`

        $ mkdir -p /home/vtrans/data/upload
        $ mkdir -p /home/vtrans/data/transcode

5. start service 

        $ rails server thin -b 10.61.0.202 

6. install torque

        $ wget http://wpfilebase.s3.amazonaws.com/torque/torque-3.0.6.tar.gz
        $ tar zxf torque-3.0.6.tar.gz
        $ cd torque-3.0.6
        $ ./configure
        $ make -j4 
        $ sudo make install

7. prepare torque, make sure torque is installed in `/usr/local` directory

        $ vi /var/spool/torque/mom_priv/config

        $pbsserver  localhost   # note: hostname running pbs_server
        $logevent   255         # bitmap of which events to log

        $ vi /var/spool/torque/server_priv/nodes

        localhost np=2 cluster01
        
        $ vi /var/spool/torque/server_name

        localhost

        # start pbs
        $ sudo script/torque.setup vtrans localhost

        # check status
        $ pbsnodes -a

8. install ffmpeg

        [ffmpeg install on CentOS] [4]
