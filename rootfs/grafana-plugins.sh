#!/bin/bash

grafana_install_plugin_command="/usr/sbin/grafana-cli"
grafana_install_plugin_args=("--pluginsDir" "/var/lib/grafana/plugins" "plugins" "install")
grafana_plugin_list=(
  "grafana-image-renderer"
  "andig-darksky-datasource"
#  "grafana-clock-panel"
#  "grafana-piechart-panel"
#  "michaeldmoore-annunciator-panel"
#  "digiapulssi-breadcrumb-panel"
#  "briangann-gauge-panel"
#  "briangann-datatable-panel"
#  "jdbranham-diagram-panel"
#  "natel-discrete-panel"
#  "savantly-heatmap-panel"
#  "mtanda-histogram-panel"
#  "digiapulssi-organisations-panel"
#  "natel-plotly-panel"
#  "bessler-pictureit-panel"
#  "vonage-status-panel"
#  "btplc-status-dot-panel"
#  "btplc-peak-report-panel"
#  "grafana-worldmap-panel"
#  "satellogic-3d-globe-panel"
#  "digiapulssi-breadcrumb-panel"
#  "btplc-trend-box-panel"
#  "neocat-cal-heatmap-panel"
#  "mtanda-histogram-panel"
#  "digrich-bubblechart-panel"
#  "digiapulssi-breadcrumb-panel"
#  "agenty-flowcharting-panel"
#  "larona-epict-panel"
#  "pierosavi-imageit-panel"
#  "michaeldmoore-multistat-panel"
#  "grafana-polystat-panel"
#  "snuids-radar-panel"
#  "scadavis-synoptic-panel"
#  "gretamosa-topology-panel"
#  "marcuscalidus-svg-panel"
#  "fatcloud-windrose-panel"
#  "snuids-trafficlights-panel"
)

for plugin in "${grafana_plugin_list[@]}"; do
  echo Installing "$plugin"
  "${grafana_install_plugin_command[@]}" "${grafana_install_plugin_args[@]}" "${plugin}"
done

chmod g+rwX /var/lib/grafana/plugins
