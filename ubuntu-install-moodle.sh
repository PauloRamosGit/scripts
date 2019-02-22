# Install Moodle pre-reqs
sudo apt-get update
sudo apt-get install php -y
sudo apt-get install php-mysql -y
sudo apt-get install php-gd -y
sudo apt-get install php-json -y
sudo apt-get install php-curl -y
sudo apt-get install php-xml -y
sudo apt-get install php-xmlrpc -y
sudo apt-get install php-zip -y
sudo apt-get install php-mbstring -y
sudo apt-get install php-soap -y
sudo apt-get install php-intl -y
sudo apt-get install libapache2-mod-php -y
sudo /etc/init.d/apache2 restart

# Install Moodle
curl -L https://download.moodle.org/download.php/direct/stable36/moodle-3.6.2.tgz > moodle.tgz
sudo tar -xvzf moodle.tgz -C /var/www/html
sudo mkdir /var/moodledata
sudo chown -R www-data /var/moodledata
sudo chmod -R 777 /var/www/html/moodle

