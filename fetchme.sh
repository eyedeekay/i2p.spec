hugo new posts/common-structures.md
hugo new posts/cryptography.md
hugo new posts/tunnel-creation.md
hugo new posts/tunnel-message.md
hugo new posts/ntcp2.md
hugo new posts/ssu.md
hugo new posts/datagrams.md
hugo new posts/ecies.md
hugo new posts/encryptedleaseset.md
hugo new posts/i2cp.md
hugo new posts/i2np.md
hugo new posts/streaming.md
hugo new posts/filter-format.md
hugo new posts/subscription.md
hugo new posts/b32encrypted.md
hugo new posts/blockfile.md
hugo new posts/configuration.md
hugo new posts/ecies-routers.md
hugo new posts/tunnel-creation-ecies.md
hugo new posts/geoip.md
hugo new posts/plugin.md
hugo new posts/red25519.md
hugo new posts/updates.md

wget -q -O - https://geti2p.net/spec/common-structures.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/common-structures.md
wget -q -O - https://geti2p.net/spec/cryptography.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/cryptography.md
wget -q -O - https://geti2p.net/spec/tunnel-creation.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/tunnel-creation.md
wget -q -O - https://geti2p.net/spec/tunnel-message.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/tunnel-message.md
wget -q -O - https://geti2p.net/spec/ntcp2.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/ntcp2.md
wget -q -O - https://geti2p.net/spec/ssu.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/ssu.md
wget -q -O - https://geti2p.net/spec/datagrams.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/datagrams.md
wget -q -O - https://geti2p.net/spec/ecies.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/ecies.md
wget -q -O - https://geti2p.net/spec/encryptedleaseset.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/encryptedleaseset.md
wget -q -O - https://geti2p.net/spec/i2cp.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/i2cp.md
wget -q -O - https://geti2p.net/spec/i2np.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/i2np.md
wget -q -O - https://geti2p.net/spec/streaming.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/streaming.md
wget -q -O - https://geti2p.net/spec/filter-format.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/filter-format.md
wget -q -O - https://geti2p.net/spec/subscription.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/subscription.md
wget -q -O - https://geti2p.net/spec/b32encrypted.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/b32encrypted.md
wget -q -O - https://geti2p.net/spec/blockfile.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/blockfile.md
wget -q -O - https://geti2p.net/spec/configuration.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/configuration.md
wget -q -O - https://geti2p.net/spec/ecies-routers.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/ecies-routers.md
wget -q -O - https://geti2p.net/spec/tunnel-creation-ecies.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/tunnel-creation-ecies.md
wget -q -O - https://geti2p.net/spec/geoip.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/geoip.md
wget -q -O - https://geti2p.net/spec/plugin.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/plugin.md
wget -q -O - https://geti2p.net/spec/red25519.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/red25519.md
wget -q -O - https://geti2p.net/spec/updates.txt | pandoc -f rst -t markdown -o - | tee -a content/posts/updates.md
