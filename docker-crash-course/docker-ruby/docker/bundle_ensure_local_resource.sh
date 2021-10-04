###
# DOC: https://robots.thoughtbot.com/fetching-source-index-for-http-rubygems-org
#

echo "!! START GEMFILE SCRIPT..."

######### SOURCES
echo "Adding sources..."
gem update --system && gem install bundler
echo "Adding temporary sources in multiple folders..."
find /mnt -name Gemfile -execdir sh -c "sed -i '1 i\source \"https://artifactory.qvantel.net/artifactory/all-gems/\"' Gemfile" \;
find /mnt -name Gemfile -execdir sh -c "sed -i '1 i\source \"https://gems.qvantel.net/\"' Gemfile" \;

echo "Adding local sources..."
gem sources -a https://artifactory.qvantel.net/artifactory/all-gems/
gem sources -a https://gems.qvantel.net/
echo "Sources correctly added..."
######### SOURCES

# declare -a sources=(
#     "https://gems.qvantel.net"
#     "https://artifactory.qvantel.net/artifactory/all-gems/"
# )
# for s in "${sources[@]}"; do
#     find -name Gemfile -execdir sh -c "sed -i '1 i\source \"$s\"' Gemfile" \;
# done

echo "Running bundle install in multiple folders..."
## RUN find -name Gemfile -execdir sh -c "pwd && bundle install" \;
# RUN find -name Gemfile -execdir sh -c "tput setaf 7; pwd && tput sgr0; bundle install" \;
# gemfile_paths=$(find /mnt -name Gemfile -execdir sh -c "pwd" \;)
# **tip: find . -path ./shared -prune -o -name Gemfile -execdir bundle install \;
#gemfile_paths_counter= $(printf '%s\n' "${gemfile_paths[@]}" | wc -w)

######### HARD-CODED FINDER - BUNDLE INSTALL
# first="0"
# declare -a gemfile_paths=('/mnt/newton/' '/mnt/form_filler/' '/mnt/report_sender/' '/mnt/components/yoicard/' '/mnt/components/tv_service/' '/mnt/components/blacklist_client/' '/mnt/components/encamina_gdpr/' '/mnt/components/vista_shared/' '/mnt/components/credit_score/' '/mnt/components/vista_location/' '/mnt/components/order_flow/' '/mnt/tienda/' '/mnt/order_status/' '/mnt/selfcare/' '/mnt/angela/' '/mnt/retail_newton/' '/mnt/selforder-tienda/' '/mnt/selforder/' '/mnt/selforder-renewal/' '/mnt/bacon/' '/mnt/pos/' '/mnt/api/')
# for p in ${gemfile_paths[@]}; do
    # if [ "$first" -eq "0" ]; then
    #     pwd && cd $p && bundle install
    #     first="1"
    # else
    #     ex +g/artifactory.qvantel.net/d -cwq $p/Gemfile
    #     ex +g/gems.qvantel.net/d -cwq $p/Gemfile
    #     pwd && cd $p && bundle install
    # fi
    # pwd && cd $p && bundle install
# done
cd /mnt/ && find -name Gemfile -execdir bundle install \;
######### HARD-CODED FINDER - BUNDLE INSTALL

######### AUTOMATIC FINDER - BUNDLE INSTALL
# gemfile_paths=$(find /mnt -name Gemfile -execdir sh -c "pwd" \;)
# for p in $gemfile_paths; do
#     pwd && cd $p && bundle install
#     ex +g/artifactory.qvantel.net/d -cwq p
#     ex +g/gems.qvantel.net/d -cwq p
# done
######### AUTOMATIC FINDER - BUNDLE INSTALL


echo "Removing sources in multiple folders..."
find -name Gemfile -execdir sh -c "sed -i '1,2d' Gemfile" \;
# RUN find -name Gemfile -execdir sh -c "sed -i '1,2d' Gemfile" \;

# echo "FIXING TCP connection to localhost:35729."
# awk 'NR==2 {$0="::1 ip6-localhost ip6-loopback"} 1' /etc/hosts
echo "!! GEMFILE SCRIPT DONE."
