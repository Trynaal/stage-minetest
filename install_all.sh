apt update -y
unzip minetest.zip
unzip irrlicht.zip
unzip minetest_game.zip
mv minetest-5.6.1 minetest
cd minetest
mv ../irrlicht-1.9.0mt9 lib/irrlichtmt
mv ../minetest_game games/
