{% from "pulsar/map.jinja" import pulsar with context %}

include:
  - .install
  - .service

pulsar-config:
  file.managed:
    - name: {{ pulsar.conf_file }}
    - source: salt://pulsar/templates/conf.jinja
    - template: jinja
    - watch_in:
      - service: pulsar_service_running
    - require:
      - pkg: pulsar
