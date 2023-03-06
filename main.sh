#!/usr/bin/env bash

replace() {
  OLD="$1"
  NEW="$2"
  TARGET="$3"

  sed -i "s/$OLD/$NEW/g" "$TARGET";
}

insert_typeorm() {
  OLD="$1"
  TARGET="$2"

  replace "${OLD}" "\"@nestjs\/typeorm\": \"^9.0.1\",\n\t\t\"mysql2\": \"^3.2.0\",\n\t\t\"typeorm\": \"^0.3.12\"," "${TARGET}";
}

insert_auth() {
  OLD="$1"
  TARGET="$2"

  replace "${OLD}" "\"@nestjs\/jwt\": \"^10.0.2\",\"@hilma\/auth\": \"^1.0.1\",\n\t\t\"cookie-parser\": \"^1.4.6\"," "${TARGET}";
}

insert_auth_types() {
  OLD="$1"
  TARGET="$2"

  replace "${OLD}" "\"@types\/cookie-parser\": \"^1.4.3\"," "${TARGET}";
}

insert_import_auth_main() {
  OLD="$1"
  TARGET="$2"

  replace "${OLD}" "import * as cookieParser from \"cookie-parser\";" "${TARGET}";
}

insert_bootstrap_auth() {
  OLD="$1"
  TARGET="$2"

  replace "${OLD}" "app.use(cookieParser());" "${TARGET}";
}

insert_import_typeorm_app() {
  OLD="$1"
  TARGET="$2"

  replace "${OLD}" "import { TypeOrmModule } from \"@nestjs\/typeorm\";" "${TARGET}";
}

insert_module_typeorm() {
  OLD="$1"
  TARGET="$2"

  replace "${OLD}" "TypeOrmModule.forRoot({\n\t\ttype: \"mysql\",\n\t\thost: \"process.env.DB_HOST\",\n\t\tport: Number(process.env.DB_PORT),\n\t\tdatabase: process.env.DB_NAME,\n\t\tusername: process.env.DB_USERNAME,\n\t\tpassword: process.env.DB_PASSWORD,\n\t\tlogging: process.env.TYPEORM_LOGGING === \"on\",\n\t\tsynchronize: process.env.TYPEORM_SYNC === \"on\",\n\n\t\tentities: [\n\t\t\t\"dist\/**\/*.entity{.ts,.js}\", \n\t\t\tAUTH PLACEHOLDER]\t\n})," "${TARGET}";
}

insert_entities_auth() {
  OLD="$1"
  TARGET="$2"

  replace "${OLD}" "\"node_modules\/@hlima\/auth-nest\/**\/*.entity{.ts,.js}\"" "${TARGET}";
}

insert_env_typeorm() {
  OLD="$1"
  TARGET="$2"

  GOAL_ON="DB_HOST=\"\"\nDB_PORT=3306\nDB_USERNAME=\"\"\nDB_PASSWORD=\"\"\nDB_NAME=\"\"\nTYPEORM_LOGGING=\"on\"\nTYPEORM_SYNC=\"on\"\n"
  GOAL_OFF="DB_HOST=\"\"\nDB_PORT=3306\nDB_USERNAME=\"\"\nDB_PASSWORD=\"\"\nDB_NAME=\"\"\nTYPEORM_LOGGING=\"off\"\nTYPEORM_SYNC=\"off\"\n"

  ORIGINAL_TARGET="$TARGET" &&
  replace "${OLD}" "$GOAL_OFF" "$TARGET.production" &&
  TARGET="$ORIGINAL_TARGET" &&
  replace "${OLD}" "$GOAL_ON" "$TARGET.development" &&
  TARGET="$ORIGINAL_TARGET" &&
  replace "${OLD}" "$GOAL_ON" "$TARGET.debug";
}

clear_typeorm() {
  NEW_PATH="$1"

  replace "TYPEORM PLACEHOLDER" "" "$NEW_PATH/package.json" &&
  replace "TYPEORM IMPORT PLACEHOLDER" "" "$NEW_PATH/src/app.module.ts" &&
  replace "TYPEORM MODULE PLACEHOLDER" "" "$NEW_PATH/src/app.module.ts" &&
  replace "TYPEORM PLACEHOLDER" "" "$NEW_PATH/.env.production" &&
  replace "TYPEORM PLACEHOLDER" "" "$NEW_PATH/.env.development" &&
  replace "TYPEORM PLACEHOLDER" "" "$NEW_PATH/.env.debug";
}


handle_typeorm() {
  IS_TYPEORM="$1"
  NEW_PATH="$2"

  if [ "$IS_TYPEORM" != true ]; then
    clear_typeorm "$NEW_PATH";
  fi

  if [ "$IS_TYPEORM" == true ]; then
    insert_typeorm "TYPEORM PLACEHOLDER" "$NEW_PATH/package.json" &&
    insert_import_typeorm_app "TYPEORM IMPORT PLACEHOLDER" "$NEW_PATH/src/app.module.ts" &&
    insert_module_typeorm "TYPEORM MODULE PLACEHOLDER" "$NEW_PATH/src/app.module.ts" &&
    insert_env_typeorm "TYPEORM PLACEHOLDER" "$NEW_PATH/.env";
  fi
}

clear_auth() {
  NEW_PATH="$1"

  replace "AUTH PLACEHOLDER" "" "$NEW_PATH/package.json" &&
  replace "AUTH TYPES PLACEHOLDER" "" "$NEW_PATH/package.json" &&
  replace "AUTH IMPORT PLACEHOLDER" "" "$NEW_PATH/src/main.ts" &&
  replace "AUTH BOOTSTRAP PLACEHOLDER" "" "$NEW_PATH/src/main.ts" &&
  replace "AUTH PLACEHOLDER" "" "$NEW_PATH/src/app.module.ts";
}

handle_auth() {
  IS_AUTH="$1"
  IS_TYPEORM="$2"
  NEW_PATH="$3"

  if [ "$IS_AUTH" != true ] || [ "$IS_TYPEORM" != true ]; then
    clear_auth "$NEW_PATH";
  fi

  if [ "$IS_AUTH" == true ] && [ "$IS_TYPEORM" == true ]; then
    insert_auth "AUTH PLACEHOLDER" "$NEW_PATH/package.json" &&
    insert_auth_types "AUTH TYPES PLACEHOLDER" "$NEW_PATH/package.json" &&
    insert_import_auth_main "AUTH IMPORT PLACEHOLDER" "$NEW_PATH/src/main.ts" &&
    insert_bootstrap_auth "AUTH BOOTSTRAP PLACEHOLDER" "$NEW_PATH/src/main.ts" &&
    insert_entities_auth "AUTH PLACEHOLDER" "$NEW_PATH/src/app.module.ts";
  fi
 }

main() {
  PROJECT_NAME=""
  IS_TYPEORM=false
  IS_AUTH=false

  THIS_FOLDER=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)

  VALID_ARGS=$(getopt -o ta --long typeorm,auth -- "$@")
  if [[ $? -ne 0 ]]; then
      exit 1;
  fi

  eval set -- "$VALID_ARGS"

  while [ : ]; do
  case "$1" in
    -t | --typeorm)
        IS_TYPEORM=true
        shift
        ;;
    -a | --auth)
        IS_AUTH=true
        shift
        ;;
    --) shift; 
        break 
        ;;
  esac
  done

  PROJECT_NAME="$1"

  if [ -z "$PROJECT_NAME" ]; then
    echo "No positional argument found for Project Name.";
    exit 1
  fi

  echo "Creating project $PROJECT_NAME...";

  if [ "$IS_TYPEORM" == true ]; then
    echo "Adding TypeORM...";
  fi

  if [ "$IS_AUTH" == true ]; then
    echo "Adding Auth...";
  fi

  cp -r "$THIS_FOLDER/server" "$PROJECT_NAME" &&
  replace SERVER_NAME "$PROJECT_NAME" "$PROJECT_NAME/README.md" &&
  replace SERVER_NAME "$PROJECT_NAME" "$PROJECT_NAME/package.json" &&
  handle_typeorm "$IS_TYPEORM" "$PROJECT_NAME" &&
  handle_auth "$IS_AUTH" "$IS_TYPEORM" "$PROJECT_NAME";
}


main $@
