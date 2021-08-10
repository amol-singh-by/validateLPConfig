import yaml
import re
import json
import jsonschema
from typing import List, Any, Union
import logging
import os


logging.basicConfig(filename="./logs/log.txt",
                    filemode='a',
                    format='%(asctime)s %(levelname)s-%(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',
                    level=logging.DEBUG)

SERVICE_DEF_PATH = os.path.join(os.path.dirname(__file__), '../config_repo/lpa/resources/config/LPA-2021.1.0.yaml')
WORKFLOW_CFG_PATH = os.path.join(os.path.dirname(__file__), '../config_repo/lpa/resources/config/workflowConfig.json')
TRANSFORM_CFG_PATH = os.path.join(os.path.dirname(__file__), '../config_repo/lpa/resources/config/transformConfig.json')

# SERVICE_DEF_PATH = r"C:\clone_develop\lde-8342\lde\src\main\resources\config-repo\ServiceRegistry\resources\configuration" \
#                    r"\service-definitions\LPA-2021.1.0.yaml "
# WORKFLOW_CFG_PATH = r"C:\clone_develop\lde-8342\lde\src\main\resources\config-repo\lpa\resources\config\workflowConfig.json"
# TRANSFORM_CFG_PATH = r"C:\clone_develop\lde-8342\lde\src\main\resources\config-repo\lpa\resources\config\transformConfig" \
#                      r".json "


def load_servicedefinition_entitylist() -> []:
    """
    :return: The list of entities from the service definition file
    """
    # Taking the SD through File Definition
    file_path = SERVICE_DEF_PATH

    with open(file_path, 'r') as yamlFile:
        try:
            data = yaml.load(yamlFile, Loader=yaml.FullLoader)
            dict_inbound: Union[List[Any], Any] = data["inbound"]
            list_request = dict_inbound.get("requests")
            list_message = []
            for message in range(len(list_request)):
                # print(list_Request[message])
                dict_message = list_request[message]
                message = dict_message.get("message")
                # print(message[5:])
                result = re.search(':(.*):', message)
                # print(result.group(1))
                list_message.append(result.group(1))

            # Remove the outbound entities as they are not present in the
            # workflowConfig.json
            list_message.remove("plannedSupply")
            list_message.remove("priceRecommendation")
            list_message.remove("applicationReceiptAcknowledgement")
            # print(list_message)
            return list_message
        except yaml.YAMLError as error:
            logging.error(error)


def load_workflowconfig_entitylist() -> []:
    """
    :return: The list of entities from the workflowConfig file
    """

    data = load_json_data("")
    keys = data["workflow"]
    return list(keys.keys())


def load_workflowconfig_subentitylist():
    """
    :return: Returns two lists
        list1: list of all the sub entities from the workflow config
        list2: list of all the target entities from the workflow config
    """
    data = load_json_data("")
    dict = data["workflow"]
    list_subentity = []
    list_targetentities = []
    for key in dict:
        dict_entity = dict[key]
        # list_subentity.append(dict_entity["targetEntities"][0]["name"])
        list_targetentities += dict_entity["targetEntities"]
        # print(dict_entity["targetEntities"])

    for ele in list_targetentities:
        list_subentity.append(ele["name"])

    return list_subentity, list_targetentities


def load_transformconfig_subentitylist():
    """
    Loads the transform config and returns the list of all the sub
    entities from the json
    :return: returns the list of all the sub entities from the transform
    config json
    """

    file_path = TRANSFORM_CFG_PATH

    data = load_json_data(file_path)
    list_subentity = list(data.keys())
    # print(list_subentity)
    return list_subentity


def diff(li1, li2):
    """
    :param li1: Takes the first list as an input
    :param li2: Takes the second list as an input
    :return: Returns the difference of elements between the two lists
    """
    return list(set(li1) - set(li2)) + list(set(li2) - set(li1))


# print(load_workflowconfig_entitylist())
# print(len(load_workflowconfig_entitylist()))
#
# print(load_servicedefinition_entitylist())
# print(len(load_servicedefinition_entitylist()))

def get_schema_workflow():
    """
    Gets the schema of file to be validated
    :return:
    """
    try:
        file_path = (r'schemaToValidate/workflowconfig_schema.json')
        # file_path = (r'C:/Users/1026979/Desktop/workflowconfig_schema.json')

        # wrkflow_schema_data = open(file_path)
        # print(wrkflow_schema_data)
        with open(file_path, 'r') as file:
            schema = json.load(file)
        return schema
    except (OSError, IOError) as error:
        print(error)

def get_schema_transform():
    """
    Gets the schema of file to be validated
    :return:
    """
    try:
        file_path = (r'schemaToValidate/transformconfig_schema.json')
        # file_path = (r'C:/Users/1026979/Desktop/transformconfig_schema.json')

        # wrkflow_schema_data = open(file_path)
        # print(wrkflow_schema_data)
        with open(file_path, 'r') as file:
            schema = json.load(file)
        return schema
    except (OSError, IOError) as error:
        print(error)

def validate_json_workflow(json_data):
    """
    :param json_data: Takes input of json data to be validated
    :return: Returns the boolean result of validation along-with the
    validation result
    """

    wrkflow_schema = get_schema_workflow()
    try:
        jsonschema.validate(instance=json_data, schema=wrkflow_schema)
    except jsonschema.exceptions.ValidationError as error:
        logging.error(error)
        err = "Given JSON data is invalid " + error.message
        return False, err, str(error)

    result = "JSON data is valid"
    return True, result, ""

def validate_json_transform(json_data):
    """
    :param json_data: Takes input of json data to be validated
    :return: Returns the boolean result of validation along-with the
    validation result
    """

    wrkflow_schema = get_schema_transform()
    try:
        jsonschema.validate(instance=json_data, schema=wrkflow_schema)
    except jsonschema.exceptions.ValidationError as error:
        logging.error(error)
        err = "Given JSON data is invalid " + error.message
        return False, err, str(error)

    result = "JSON data is valid"
    return True, result

def load_json_data(file_path: str):
    try:
        if file_path == "":
            file_path = WORKFLOW_CFG_PATH

        wrkflow_file_data = open(file_path)

        data = json.load(wrkflow_file_data)
        return data
    except (OSError, IOError) as error:
        print(error)


def checkdatepolicy_incrementaldate_dependency_workflowconfig():
    targetentity_list = load_workflowconfig_subentitylist()[1]
    incrementaldate_error_list = []
    for ele in targetentity_list:
        try:
            if str(ele["datePolicy"]).casefold() == "next_day":
                if "incrementalDate" in ele.keys():
                    pass
                else:
                    incrementaldate_error_list.append(ele)
        except KeyError as error:
            pass
    return incrementaldate_error_list


def checkdailyandhistorical_presence_workflowconfig():
    """
    :return: return the list of daily or historical entity missing from
    transform config configuration
    """
    file_path = TRANSFORM_CFG_PATH

    data = load_json_data(file_path)
    list_missingdailyhistorical = []
    for ele in load_transformconfig_subentitylist():
        if "daily" in data[ele]:
            pass
        else:
            list_missingdailyhistorical.append("Missing daily in {} : {}".format(ele, data[ele]))
        if "historical" in data[ele]:
            pass
        else:
            list_missingdailyhistorical.append("Missing historical in {} : {}".format(ele, data[ele]))

    return list_missingdailyhistorical


def validate_del_file_for_fc():
    wrkflow_cfg = json.load(open(WORKFLOW_CFG_PATH))
    tran_cfg = json.load(open(TRANSFORM_CFG_PATH))
    sd = yaml.load(open(SERVICE_DEF_PATH), Loader=yaml.FullLoader)
    sd_map = dict()

    for d in sd.get('inbound').get('requests'):
        entity = d.get('message').split(':')[1]
        entity_version = d.get('message').split(' ')[-1]
        sd_map[entity] = entity_version

    list_missing_delete_files = []
    for entity in wrkflow_cfg.get('workflow').keys():
        for target_entity in wrkflow_cfg.get('workflow').get(entity).get('targetEntities'):
            if target_entity.get('deleteApplicable'):
                entity_name = target_entity.get('name')
                entity_version = sd_map.get(entity)
                for input_type in tran_cfg.get(entity_name).get('daily'):
                    if not (tran_cfg.get(entity_name).get('daily').get(input_type).get(entity_version).get('delete')):
                        list_missing_delete_files.append(entity_name)

    return list_missing_delete_files


def validate_del_for_historical():
    tran_cfg = json.load(open(TRANSFORM_CFG_PATH))

    list_has_del_for_historical = []
    for entity in tran_cfg.keys():
        for input_type in tran_cfg.get(entity).get('historical').keys():
            for version in tran_cfg.get(entity).get('historical').get(input_type):
                if tran_cfg.get(entity).get('historical').get(input_type).get(version).get('delete'):
                    list_has_del_for_historical.append(entity)

    return list_has_del_for_historical


def validate_transform_config_versions_with_sd():
    wrkflow_cfg = json.load(open(WORKFLOW_CFG_PATH))
    tran_cfg = json.load(open(TRANSFORM_CFG_PATH))
    sd = yaml.load(open(SERVICE_DEF_PATH), Loader=yaml.FullLoader)
    sd_map = dict()
    entity_map = dict()

    for d in sd.get('inbound').get('requests'):
        entity = d.get('message').split(':')[1]
        entity_version = d.get('message').split(' ')[-1]
        sd_map[entity] = entity_version

    for entity in wrkflow_cfg.get('workflow').keys():
        for target_entity in wrkflow_cfg.get('workflow').get(entity).get('targetEntities'):
            entity_name = target_entity.get('name')
            entity_map[entity_name] = entity

    list_has_incorrect_versions = []
    for entity in tran_cfg.keys():
        for flow_mode in tran_cfg.get(entity).keys():
            for input_type in tran_cfg.get(entity).get(flow_mode).keys():
                for version in tran_cfg.get(entity).get(flow_mode).get(input_type).keys():
                    if sd_map.get(entity_map[entity]) != version:
                        list_has_incorrect_versions.append(f'{entity} in {flow_mode} flow mode for {input_type} input')

    return list_has_incorrect_versions


def validate_json_type_in_transform_config():
    tran_cfg = json.load(open(TRANSFORM_CFG_PATH))

    list_no_json_supported = []
    for entity in tran_cfg.keys():
        for flow_mode in tran_cfg.get(entity).keys():
            if 'json' not in tran_cfg.get(entity).get(flow_mode).keys():
                list_no_json_supported.append(entity)

    return list_no_json_supported


def check_sequence(arr):
    if len(arr) == 0:
        return True
    elif len(arr) == 1:
        return True if arr[0] == 1 else False
    else:
        for i in range(0, len(arr)):
            if arr[i] != 1 + i:
                return False

        return True


def validate_sequence_nos_workflow_config():
    wrkflow_cfg = json.load(open(WORKFLOW_CFG_PATH))

    list_wrong_seq_of_entities = []
    for entity in wrkflow_cfg.get('workflow').keys():
        seq = [x.get('sequenceNo') for x in wrkflow_cfg.get('workflow').get(entity).get('targetEntities')]
        if not check_sequence(seq):
            list_wrong_seq_of_entities.append(entity)

    return list_wrong_seq_of_entities


# Testing the scenarios
validation_report_dict = {}
# Test for workflowconfig.json schema validation - 1
logging.info("Test for workflowconfig.json schema validation:::")
logging.info((validate_json_workflow(load_json_data(""))))
validation_report_dict['Test for workflowconfig.json schema validation'] = validate_json_workflow(load_json_data(""))
logging.info("===================================================================================================================================================\n")

# Test for transformconfig.json schema validation - 2
logging.info("Test for transformconfig.json schema validation:::")
logging.info((validate_json_transform(load_json_data(TRANSFORM_CFG_PATH))))
validation_report_dict['Test for transformconfig.json schema validation'] = validate_json_transform(load_json_data(TRANSFORM_CFG_PATH))
logging.info("===================================================================================================================================================\n")

# Test for Service Definition and Workflow dependency - 2
logging.info("Test for Service Definition and Workflow dependency:::")
logging.info(diff(load_workflowconfig_entitylist(), load_servicedefinition_entitylist()))
validation_report_dict['Test for Service Definition and Workflow dependency'] = diff(load_workflowconfig_entitylist(), load_servicedefinition_entitylist())
logging.info("===================================================================================================================================================\n")

# Test for workflow and transformConfig dependency - 3
logging.info("Test for workflow and transformConfig dependency:::")
logging.info(diff(load_workflowconfig_subentitylist()[0], load_transformconfig_subentitylist()))
validation_report_dict['Test for workflow and transformConfig dependency'] = diff(load_workflowconfig_subentitylist()[0], load_transformconfig_subentitylist())
logging.info("===================================================================================================================================================\n")

# Test for incremental date when NEXT_DAY present in the workflowConfig - 9
logging.info("Test for incremental date when NEXT_DAY present in the workflowConfig:::")
logging.info(checkdatepolicy_incrementaldate_dependency_workflowconfig())
validation_report_dict['Test for incremental date when NEXT_DAY present in the workflowConfig'] = checkdatepolicy_incrementaldate_dependency_workflowconfig()
logging.info("===================================================================================================================================================\n")

# Test for daily and historical present in the transformConfig for every entity - 15
logging.info("Test for daily and historical present in the transformConfig for every entity:::")
validateDelForHistorical = checkdailyandhistorical_presence_workflowconfig()
logging.info(validateDelForHistorical)
validation_report_dict['Test for daily and historical present in the transformConfig for every entity'] = validateDelForHistorical
logging.info("===================================================================================================================================================\n")


# Verify if a path is given for the "Delete" action for an entity if force delete is enabled
logging.info("Verify if a path is given for the 'Delete' action for an entity if force delete is enabled:::")
logging.info(validate_del_file_for_fc())
validation_report_dict["Verify if a path is given for the 'Delete' action for an entity if force delete is enabled"] = validate_del_file_for_fc()
logging.info("===================================================================================================================================================\n")


# Verify if there are any delete DWL paths for historical flows
logging.info("Verify if there are any delete DWL paths for historical flows:::")
if (len(validateDelForHistorical) == 0):
    logging.info(validate_del_for_historical())
    validation_report_dict["Verify if there are any delete DWL paths for historical flows"] = validate_del_for_historical()
    logging.info("===================================================================================================================================================\n")


# Validate message versions in transform config
logging.info("Validate message versions in transform config:::")
logging.info(validate_transform_config_versions_with_sd())
validation_report_dict["Validate message versions in transform config"] = validate_transform_config_versions_with_sd()
logging.info("===================================================================================================================================================\n")


# Validate if all entities in transform config support json
logging.info("Validate if all entities in transform config support json:::")
logging.info(validate_json_type_in_transform_config())
validation_report_dict["Validate if all entities in transform config support json"] = validate_json_type_in_transform_config()
logging.info("===================================================================================================================================================\n")


# Validate the sequence of entitiies in workflow_
logging.info("Validate the sequence of entitiies in workflow:::")
logging.info(validate_sequence_nos_workflow_config())
validation_report_dict["Validate the sequence of entitiies in workflow"] = validate_sequence_nos_workflow_config()
logging.info("===================================================================================================================================================\n")


# validation_report_dict = {'validation': [
#     {"Test":  "Test for workflowconfig.json schema validation",
#         "result": validate_json_workflow(load_json_data(""))
#     },
#     {"Test":  "Test for Service Definition and Workflow dependency",
#      "result": validate_json_workflow(load_json_data(""))
#      },
#     {"Test":  "Test for workflowconfig.json schema validation",
#      "result": validate_json_workflow(load_json_data(""))
#      },
#     {"Test":  "Test for workflowconfig.json schema validation",
#      "result": validate_json_workflow(load_json_data(""))
#      }
#                     ]
#                }


validate_report_json = json.dumps(validation_report_dict, indent=4)

with open('./target/report.json', 'w') as f:
    f.write(validate_report_json)
