{% from "pulsar/map.jinja" import pulsar, apache_mirror with context %}

include:
  - .service

create_pulsar_user:
  user.present:
    - name: {{ pulsar.user }}
    - shell: /bin/false

install_pulsar_dependencies:
  pkg.installed:
    - pkgs: {{ pulsar.pkgs }}

install_pulsar_from_archive:
  archive.extracted:
    - name: /opt/
    - source: {{ apache_mirror.preferred_url }}pulsar/pulsar-{{ pulsar.version }}/apache-pulsar-{{ pulsar.version }}-bin.tar.gz
    - source_hash: {{ apache_mirror.backup_url }}pulsar/pulsar-{{ pulsar.version }}/apache-pulsar-{{ pulsar.version }}-bin.tar.gz.sha512
    - user: {{ pulsar.user }}
    - group: {{ pulsar.group }}
    - enforce_ownership_on: /opt/apache-pulsar-{{ pulsar.version }}/
    - require:
        - pkg: install_pulsar_dependencies
        - user: create_pulsar_user
    - require_in:
        {% for service_name in pulsar.services %}
        - service: pulsar_{{ service_name }}_service_running
        {% endfor %}
  file.symlink:
    - name: /opt/pulsar
    - target: /opt/apache-pulsar-{{ pulsar.version }}
    - user: {{ pulsar.user }}
    - group: {{ pulsar.group }}
    - require:
        - archive: install_pulsar_from_archive

{% if pulsar.install_offloaders %}
install_pulsar_tiered_storage_offloaders:
  archive.extracted:
    - name: /tmp/
    - source: {{ apache_mirror.preferred_url }}pulsar/pulsar-{{ pulsar.version }}/apache-pulsar-offloaders-{{ pulsar.version }}-bin.tar.gz
    - source_hash: {{ apache_mirror.backup_url }}pulsar/pulsar-{{ pulsar.version }}/apache-pulsar-offloaders-{{ pulsar.version }}-bin.tar.gz.sha512
    - user: {{ pulsar.user }}
    - group: {{ pulsar.group }}
    {% if 'broker' in pulsar.services %}
    - require_in:
        - service: pulsar_broker_service_running
    {% endif %}
  file.rename:
    - name: /opt/apache-pulsar-{{ pulsar.version }}/offloaders
    - source: /tmp/apache-pulsar-offloaders-{{ pulsar.version }}/offloaders
    - force: True
{% endif %}

create_pulsar_log_directory:
  file.directory:
    - name: {{ pulsar.env.PULSAR_LOG_DIR }}
    - user: {{ pulsar.user }}
    - group: {{ pulsar.group }}
    - recurse:
        - user
        - group

create_pulsar_env_file:
  file.managed:
    - name: /etc/defaults/pulsar
    - source: salt://pulsar/templates/conf.jinja
    - template: jinja
    - context:
        settings: {{ pulsar.env|json }}
    - makedirs: True

{% for service_name in pulsar.services %}
create_{{ service_name }}_service_definition:
  file.managed:
    - name: /etc/systemd/system/pulsar-{{ service_name }}.service
    - source: salt://pulsar/templates/pulsar.service.j2
    - template: jinja
    - context:
        service_name: {{ service_name }}
    - require_in:
        - service: pulsar_{{ service_name }}_service_running
    - require:
        - archive: install_pulsar_from_archive
  cmd.wait:
    - name: systemctl daemon-reload
    - watch:
        - file: create_{{ service_name }}_service_definition
    - require_in:
        - service: pulsar_{{ service_name }}_service_running
{% endfor %}
