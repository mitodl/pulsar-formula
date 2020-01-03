{% from "pulsar/map.jinja" import pulsar with context %}

pulsar_service_running:
  service.running:
    - name: {{ pulsar.service }}
    - enable: True
