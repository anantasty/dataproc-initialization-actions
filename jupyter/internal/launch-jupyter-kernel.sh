#!/bin/bash

# This script creates systemd configuration for Jupyter.

set -euxo pipefail

echo "Installing Jupyter service..."

# Create a separate runner file to make it easier to pull in the right
# environment variables, etc,. before launching the notebook.
readonly JUPYTER_LAUNCHER='/usr/local/bin/launch_jupyterlab.sh'
readonly INIT_SCRIPT='/usr/lib/systemd/system/jupyter-lab.service'

cat << EOF > "${JUPYTER_LAUNCHER}"
#!/bin/bash

source /etc/profile.d/conda.sh
/opt/conda/bin/jupyter lab --allow-root --no-browser
EOF
chmod 750 "${JUPYTER_LAUNCHER}"

cat << EOF > "${INIT_SCRIPT}"
[Unit]
Description=Jupyter Lab Notebook Server

[Service]
Type=simple
Restart=on-failure
ExecStart=/bin/bash -c 'exec ${JUPYTER_LAUNCHER} \
    &> /var/log/jupyter_notebook.log'

[Install]
WantedBy=multi-user.target
EOF

chmod a+rw "${INIT_SCRIPT}"

echo "Starting Jupyter notebook..."

systemctl daemon-reload
systemctl enable jupyter-lab
systemctl restart jupyter-lab
systemctl status jupyter-lab

echo "Jupyter installation succeeded" >&2
