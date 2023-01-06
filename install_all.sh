apt update -y
unzip minetest.zip
unzip irrlicht.zip
unzip minetest_game.zip
mv minetest-5.6.1 minetest
mv irrlicht-1.9.0mt9 minetest/lib/irrlichtmt
mv minetest_game-5.6.1 minetest/games/minetest_game
mv mods minetest/games/minetest_games/mods/
sudo apt install -y g++ make libc6-dev cmake libpng-dev libjpeg-dev libxi-dev libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev libopenal-dev libcurl4-gnutls-dev libfreetype6-dev zlib1g-dev libgmp-dev libjsoncpp-dev libzstd-dev libluajit-5.1-dev
cd minetest
cmake . -DRUN_IN_PLACE=TRUE -DBUILD_SERVER=TRUE -DBUILD_CLIENT=FALSE -DENABLE_CURL=ON -DENABLE_LUAJIT=ON .
make -j$(nproc)