{% from "pulsar/map.jinja" import pulsar, apache_mirror with context %}

{% for connector in pulsar.io_connectors %}
install_pulsar_io_connector_{{ connector }}:
  file.managed:
    - name: /opt/pulsar/connectors/pulsar-io-{{ connector }}-{{ pulsar.version }}.nar
    - source: {{ apache_mirror.preferred_url }}pulsar/pulsar-{{ pulsar.version }}/connectors/pulsar-io-{{ connector }}-{{ pulsar.version }}.nar
    - source_hash: {{ apache_mirror.backup_url }}pulsar/pulsar-{{ pulsar.version }}/connectors/pulsar-io-{{ connector }}-{{ pulsar.version }}.nar.sha512
    - user: {{ pulsar.user }}
    - group: {{ pulsar.group }}
    - makedirs: True
{% endfor %}

# After installing a connector it is necessary to reload the list of classes.
# This is also dependent on whether it is a source, sink, or both. The command
# is of the form: `bin/pulsar-admin <sources|sinks> reload
