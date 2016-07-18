
grep -A3 -P "ESME:\s|Direction:|command_id:|short_message:|message_id:|sequence_number:|destination_addr:|source_addr:|^Time:|tag: 0x0424 message_payload|tag: 0x0501 ussd_service_op" |grep -vP "^--$|^From:|^To:|^PDU|^Decode|^\[|command_status:|service_type:|source_addr_|dest_addr_|^[0-9A-F]{8}\s[0-9A-F\s]*$|esm_class:|registered_delivery:|data_coding:|len:" 

