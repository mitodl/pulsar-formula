{% from "pulsar/map.jinja" import pulsar with context %}

include:
  - .service

pulsar:
  pkg.installed:
    - pkgs: {{ pulsar.pkgs }}
    - require_in:
        - service: pulsar_service_running
