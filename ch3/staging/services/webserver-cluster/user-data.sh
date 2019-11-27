#!/bin/bash

cat > index.html <<EOF
<h1>Terraform Cluster</h1>
<p>DB FQDN: ${db_fqdn}</p>
<p>DB Port: ${db_port}</p>
<p>Thanks for stopping by</p>
EOF

nohup busybox httpd -f -p ${server_port} &

