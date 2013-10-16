metadata :name        => "Rproxy",
         :description => "Rproxy service for MCollective",
         :author      => "Worldline",
         :license     => "Apache",
         :version     => "0.2",
         :url         => "http://worldline.com/",
         :timeout     => 60

action "conf", :description => "Reverse proxy conf"  do

     input :appname,
         :prompt      => "Appname",
         :description => "Application name",
         :type        => :string,
         :validation  => '^[a-zA-Z0-9\.\-\/]+$', 
         :optional    => false,
         :maxlength   => 80

     input :domainname,
         :prompt      => "Domainname",
         :description => "Dns application suffix",
         :type        => :string,
         :validation  => '^[a-zA-Z0-9\.\-\/]+$', 
         :optional    => false,
         :maxlength   => 80

     input :appalias,
         :prompt      => "Appalias",
         :description => "Application aliases",
         :type        => :string,
         :validation  => '^[a-zA-Z0-9\.\-\/\ ]+$', 
         :optional    => true,
         :maxlength   => 200

    input :args,
        :prompt         => "Args",
        :description    => "IP, ports pair providing the service",
        :type           => :string,
        :validation  => '^[\.:\d\ ]+$',
        :optional       => false,
        :maxlength   => 200

    output :exitcode,
         :description => "Exit code",
        :display_as => "Exit Code"

end

action "unconfigure", :description => "Params conf reverse proxy"  do

     input :appname,
         :prompt      => "Appname",
         :description => "Application long name",
         :type        => :string,
         :validation  => '^[a-zA-Z0-9\.\-\/]+$', 
         :optional    => false,
         :maxlength   => 80

     input :domainname,
         :prompt      => "Domainname",
         :description => "Dns application suffix",
         :type        => :string,
         :validation  => '^[a-zA-Z0-9\.\-\/]+$', 
         :optional    => false,
         :maxlength   => 80

    output :exitcode,
         :description => "Exit code",
        :display_as => "Exit Code"
end
