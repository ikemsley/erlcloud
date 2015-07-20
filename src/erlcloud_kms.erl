-module(erlcloud_kms).
-author('rorra@rorra.com.ar').

-include("erlcloud.hrl").
-include("erlcloud_aws.hrl").

-define(API_VERSION, "2014-11-01").

%%% Library initialization.
-export([configure/2, configure/3, configure/4, new/2, new/3, new/4]).

%%% KMS API
-export([create_alias/2, create_alias/3,
         create_grant/2, create_grant/3, create_grant/4,
         create_key/0, create_key/1, create_key/2,
         decrypt/1, decrypt/2, decrypt/3,
         delete_alias/1, delete_alias/2,
         describe_key/1, describe_key/2,
         disable_key/1, disable_key/2,
         disable_key_rotation/1, disable_key_rotation/2,
         enable_key/1, enable_key/2,
         enable_key_rotation/1, enable_key_rotation/2,
         encrypt/2, encrypt/3, encrypt/4,
         generate_data_key/1, generate_data_key/2, generate_data_key/3,
         generate_data_key_without_plaintext/1, generate_data_key_without_plaintext/2, generate_data_key_without_plaintext/3,
         generate_random/1, generate_random/2,
         get_key_policy/2, get_key_policy/3,
         get_key_rotation_status/1, get_key_rotation_status/2,
         list_aliases/0, list_aliases/1, list_aliases/2,
         list_grants/1, list_grants/2, list_grants/3,
         list_key_policies/1, list_key_policies/2, list_key_policies/3,
         list_keys/0, list_keys/1, list_keys/2,
         put_key_policy/3, put_key_policy/4,
         re_encrypt/2, re_encrypt/3, re_encrypt/4,
         retire_grant/1, retire_grant/2,
         revoke_grant/2, revoke_grant/3,
         update_alias/2, update_alias/3,
         update_key_description/2, update_key_description/3]).


%%%------------------------------------------------------------------------------
%%% Shared types
%%%------------------------------------------------------------------------------
-type pagination_opts() :: [pagination_opt()].
-type pagination_opt() :: {limit, non_neg_integer()} | {marker, string()}.


%%%------------------------------------------------------------------------------
%%% Library initialization.
%%%------------------------------------------------------------------------------

-spec new(string(), string()) -> aws_config().

new(AccessKeyID, SecretAccessKey) ->
    #aws_config{
       access_key_id=AccessKeyID,
       secret_access_key=SecretAccessKey
      }.

-spec new(string(), string(), string()) -> aws_config().

new(AccessKeyID, SecretAccessKey, Host) ->
    #aws_config{
       access_key_id=AccessKeyID,
       secret_access_key=SecretAccessKey,
       s3_host=Host
      }.

-spec new(string(), string(), string(), non_neg_integer()) -> aws_config().

new(AccessKeyID, SecretAccessKey, Host, Port) ->
    #aws_config{
       access_key_id=AccessKeyID,
       secret_access_key=SecretAccessKey,
       s3_host=Host,
       s3_port=Port
      }.

-spec configure(string(), string()) -> ok.

configure(AccessKeyID, SecretAccessKey) ->
    put(aws_config, new(AccessKeyID, SecretAccessKey)),
    ok.

-spec configure(string(), string(), string()) -> ok.

configure(AccessKeyID, SecretAccessKey, Host) ->
    put(aws_config, new(AccessKeyID, SecretAccessKey, Host)),
    ok.

-spec configure(string(), string(), string(), non_neg_integer()) -> ok.

configure(AccessKeyID, SecretAccessKey, Host, Port) ->
    put(aws_config, new(AccessKeyID, SecretAccessKey, Host, Port)),
    ok.

default_config() ->
    erlcloud_aws:default_config().

%%%------------------------------------------------------------------------------
%%% CreateAlias
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_CreateAlias.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec create_alias/2 ::
          (AliasName :: string(),
           TargetKeyId :: string()) ->
          any().
create_alias(AliasName, TargetKeyId) ->
    create_alias(AliasName, TargetKeyId, default_config()).


-spec create_alias/3 ::
          (AliasName :: string(),
           TargetKeyId :: string(),
           Config :: aws_config()) ->
          any().
create_alias(AliasName, TargetKeyId, Config) ->
    Json = [{<<"AliasName">>, AliasName}, {<<"TargetKeyId">>, TargetKeyId}],
    erlcloud_kms_impl:request(Config, "TrentService.CreateAlias", Json).	


%%%------------------------------------------------------------------------------
%%% CreateGrant
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_CreateGrant.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-type create_grant_opts() :: [create_grant_opt()].
-type create_grant_opt() :: {create_grant_opt_key(), term()}.
-type create_grant_opt_key() :: grant_tokens | operations | grantee_principal.


-spec create_grant/2 ::
          (GranteePrincipal :: string(),
           KeyId :: string()) ->
          any().
create_grant(GranteePrincipal, KeyId) ->
    create_grant(GranteePrincipal, KeyId, []).


-spec create_grant/3 ::
          (GranteePrincipal :: string(),
           KeyId :: string(),
           Options :: create_grant_opts()) ->
          any().
create_grant(GranteePrincipal, KeyId, Options) ->
    create_grant(GranteePrincipal, KeyId, Options, default_config()).


-spec create_grant/4 ::
          (GranteePrincipal :: string(),
           KeyId :: string(),
           Options :: create_grant_opts(),
           Config :: aws_config()) ->
          any().
create_grant(GranteePrincipal, KeyId, Options, Config) ->
    OptJson = dynamize_options(Options),
    Json = [{<<"GranteePrincipal">>, GranteePrincipal},
            {<<"KeyId">>, KeyId}|OptJson],
    erlcloud_kms_impl:request(Config, "TrentService.CreateGrant", Json).


%%%------------------------------------------------------------------------------
%%% CreateKey
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_CreateKey.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-type create_key_opts() :: [create_key_opt()].
-type create_key_opt() :: [{create_key_opt_key(), term()}].
-type create_key_opt_key() :: description | key_usage | policy.


-spec create_key/0 :: () -> any().
create_key() ->
    create_key([]).


-spec create_key/1 ::
          (Options :: create_key_opts()) ->
          any().
create_key(Options) ->
    create_key(Options, default_config()).


-spec create_key/2 ::
          (Options :: create_key_opts(),
           Config :: aws_config()) ->
          any().
create_key(Options, Config) ->
    Json = dynamize_options(Options),
    erlcloud_kms_impl:request(Config, "TrentService.CreateKey", Json).


%%%------------------------------------------------------------------------------
%%% Decrypt
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_Decrypt.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-type decrypt_opts() :: [decrypt_opt()].
-type decrypt_opt() :: {decrypt_opt_key(), term()}.
-type decrypt_opt_key() :: encryption_context | grant_tokens.


-spec decrypt/1 ::
          (CiphertextBlob :: binary()) ->
          any().
decrypt(CiphertextBlob) ->
    decrypt(CiphertextBlob, []).


-spec decrypt/2 ::
          (CiphertextBlob :: binary(),
           Options :: decrypt_opts()) ->
          any().
decrypt(CiphertextBlob, Options) ->
    decrypt(CiphertextBlob, Options, default_config()).


-spec decrypt/3 ::
          (CiphertextBlob :: binary(),
           Options :: decrypt_opts(),
           Config :: aws_config()) ->
          any().
decrypt(CiphertextBlob, Options, Config) ->
    OptJson = dynamize_options(Options),
    Json = [{<<"CiphertextBlob">>, CiphertextBlob}|OptJson],
    erlcloud_kms_impl:request(Config, "TrentService.Decrypt", Json).


%%%------------------------------------------------------------------------------
%%% DeleteAlias
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_DeleteAlias.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec delete_alias/1 ::
          (AliasName :: string()) ->
          any().
delete_alias(AliasName) ->
    delete_alias(AliasName, default_config()).


-spec delete_alias/2 ::
          (AliasName :: string(),
           Config :: aws_config()) ->
          any().
delete_alias(AliasName, Config) ->
    Json = [{<<"AliasName">>, AliasName}],
    erlcloud_kms_impl:request(Config, "TrentService.DeleteAlias", Json).


%%%------------------------------------------------------------------------------
%%% DescribeKey
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_DescribeKey.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec describe_key/1 ::
          (KeyId :: string()) ->
          any().
describe_key(KeyId) ->
    describe_key(KeyId, default_config()).


-spec describe_key/2 ::
          (KeyId :: string(),
           Config :: aws_config()) ->
          any().
describe_key(KeyId, Config) ->
    Json = [{<<"KeyId">>, KeyId}],
    erlcloud_kms_impl:request(Config, "TrentService.DescribeKey", Json).


%%%------------------------------------------------------------------------------
%%% DisableKey
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_DisableKey.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec disable_key/1 ::
          (KeyId :: string()) ->
          any().
disable_key(KeyId) ->
    disable_key(KeyId, default_config()).


-spec disable_key/2 ::
          (KeyId :: string(),
           Config :: aws_config()) ->
          any().
disable_key(KeyId, Config) ->
    Json = [{<<"KeyId">>, KeyId}],
    erlcloud_kms_impl:request(Config, "TrentService.DisableKey", Json).


%%%------------------------------------------------------------------------------
%%% DisableKeyRotation
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_DisableKeyRotation.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec disable_key_rotation/1 ::
          (KeyId :: string()) ->
          any().
disable_key_rotation(KeyId) ->
    disable_key_rotation(KeyId, default_config()).


-spec disable_key_rotation/2 ::
          (KeyId :: string(),
           Config :: aws_config()) ->
          any().
disable_key_rotation(KeyId, Config) ->
    Json = [{<<"KeyId">>, KeyId}],
    erlcloud_kms_impl:request(Config, "TrentService.DisableKey", Json).


%%%------------------------------------------------------------------------------
%%% EnableKey
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_EnableKeyRotation.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec enable_key/1 ::
          (KeyId :: string()) ->
          any().
enable_key(KeyId) ->
    enable_key(KeyId, default_config()).

-spec enable_key/2 ::
          (KeyId :: string(),
           Config :: aws_config()) ->
          any().
enable_key(KeyId, Config) ->
    Json = [{<<"KeyId">>, KeyId}],
    erlcloud_kms_impl:request(Config, "TrentService.EnableKey", Json).


%%%------------------------------------------------------------------------------
%%% EnableKeyRotation
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_EnableKeyRotation.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec enable_key_rotation/1 ::
          (KeyId :: string()) ->
          any().
enable_key_rotation(KeyId) ->
    enable_key_rotation(KeyId, default_config()).


-spec enable_key_rotation/2 ::
          (KeyId :: string(),
           Config :: aws_config()) ->
          any().
enable_key_rotation(KeyId, Config) ->
    Json = [{<<"KeyId">>, KeyId}],
    erlcloud_kms_impl:request(Config, "TrentService.EnableKeyRotation", Json).


%%%------------------------------------------------------------------------------
%%% Encrypt
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_Encrypt.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-type encrypt_opts() :: [encrypt_opt()].
-type encrypt_opt() :: {encrypt_opt_key(), term()}.
-type encrypt_opt_key() :: encryption_context | grant_tokens.


-spec encrypt/2 ::
          (KeyId :: string(),
           Plaintext :: string()) ->
          any().
encrypt(KeyId, Plaintext) ->
    encrypt(KeyId, Plaintext, []).


-spec encrypt/3 ::
          (KeyId :: string(),
           Plaintext :: string(),
           Options :: encrypt_opts()) ->
          any().
encrypt(KeyId, Plaintext, Options) ->
    encrypt(KeyId, Plaintext, Options, default_config()).


-spec encrypt/4 ::
          (KeyId :: string(),
           Plaintext :: string(),
           Options :: encrypt_opts(),
           Config :: aws_config()) ->
          any().
encrypt(KeyId, Plaintext, Options, Config) ->
    OptJson = dynamize_options(Options),
    Json = [{<<"KeyId">>, KeyId}, {<<"Plaintext">>, Plaintext}|OptJson],
    erlcloud_kms_impl:request(Config, "TrentService.Encrypt", Json).


%%%------------------------------------------------------------------------------
%%% GenerateDataKey
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_GenerateDataKey.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-type generate_data_key_opts() :: [generate_data_key_opt()].
-type generate_data_key_opt() :: {generate_data_key_opt_key(), term()}.
-type generate_data_key_opt_key() :: encryption_context | grant_tokens | key_spec | number_of_bytes.


-spec generate_data_key/1 ::
          (KeyId :: string()) ->
          any().
generate_data_key(KeyId) ->
    generate_data_key(KeyId, []).


-spec generate_data_key/2 ::
          (KeyId :: string(),
           Options :: generate_data_key_opts()) ->
          any().
generate_data_key(KeyId, Options) ->
    generate_data_key(KeyId, Options, default_config()).


-spec generate_data_key/3 ::
          (KeyId :: string(),
           Options :: generate_data_key_opts(),
           Config :: aws_config()) ->
          any().
generate_data_key(KeyId, Options, Config) ->
    OptJson = dynamize_options(Options),
    Json = [{<<"KeyId">>, KeyId}|OptJson],
    erlcloud_kms_impl:request(Config, "TrentService.GenerateDataKey", Json).


%%%------------------------------------------------------------------------------
%%%------------------------------------------------------------------------------
%%% GenerateDataKeyWithoutPlaintext
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_GenerateDataKeyWithoutPlaintext.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec generate_data_key_without_plaintext/1 ::
          (KeyId :: string()) ->
          any().
generate_data_key_without_plaintext(KeyId) ->
    generate_data_key_without_plaintext(KeyId, []).


-spec generate_data_key_without_plaintext/2 ::
          (KeyId :: string(),
           Options :: generate_data_key_opts()) ->
          any().
generate_data_key_without_plaintext(KeyId, Options) ->
    generate_data_key_without_plaintext(KeyId, Options, default_config()).


-spec generate_data_key_without_plaintext/3 ::
          (KeyId :: string(),
           Options :: generate_data_key_opts(),
           Config :: aws_config()) ->
          any().
generate_data_key_without_plaintext(KeyId, Options, Config) ->
    OptJson = dynamize_options(Options),
    Json = [{<<"KeyId">>, KeyId}|OptJson],
    erlcloud_kms_impl:request(Config, "TrentService.GenerateDataKeyWithoutPlaintext", Json).


%%%------------------------------------------------------------------------------
%%% GenerateRandom
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_GenerateRandom.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec generate_random/1 ::
          (NumberOfBytes :: non_neg_integer()) ->
          any().
generate_random(NumberOfBytes) ->
    generate_random(NumberOfBytes, default_config()).


-spec generate_random/2 ::
          (NumberOfBytes :: non_neg_integer(),
           Config :: aws_config()) ->
          any().
generate_random(NumberOfBytes, Config) ->
    Json = [{<<"NumberOfBytes">>, NumberOfBytes}],
    erlcloud_kms_impl:request(Config, "TrentService.GenerateRandom", Json).


%%%------------------------------------------------------------------------------
%%% GetKeyPolicy
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_GetKeyPolicy.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec get_key_policy/2 ::
          (KeyId :: string(),
           PolicyName :: string()) ->
          any().
get_key_policy(KeyId, PolicyName) ->
    get_key_policy(KeyId, PolicyName, default_config()).


-spec get_key_policy/3 ::
          (KeyId :: string(),
           PolicyName :: string(),
           Config :: aws_config()) ->
          any().
get_key_policy(KeyId, PolicyName, Config) ->
    Json = [{<<"KeyId">>, KeyId}, {<<"PolicyName">>, PolicyName}],
    erlcloud_kms_impl:request(Config, "TrentService.GetKeyPolicy", Json).


%%%------------------------------------------------------------------------------
%%% GetKeyRotationStatus
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_GetKeyRotationStatus.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec get_key_rotation_status/1 ::
          (KeyId :: string()) ->
          any().
get_key_rotation_status(KeyId) ->
    get_key_rotation_status(KeyId, default_config()).


-spec get_key_rotation_status/2 ::
          (KeyId :: string(),
           Config :: aws_config()) ->
          any().
get_key_rotation_status(KeyId, Config) ->
    Json = [{<<"KeyId">>, KeyId}],
    erlcloud_kms_impl:request(Config, "TrentService.GetKeyRotationStatus", Json).


%%%------------------------------------------------------------------------------
%%% ListAliases
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_ListAliases.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec list_aliases/0 ::
          () ->
          any().
list_aliases() ->
    list_aliases([]).


-spec list_aliases/1 ::
          (Options :: pagination_opts()) ->
          any().
list_aliases(Options) ->
    list_aliases(Options, default_config()).


-spec list_aliases/2 ::
          (Options :: pagination_opts(),
           Config :: aws_config()) ->
          any().
list_aliases(Options, Config) ->
    Json = dynamize_options(Options),
    erlcloud_kms_impl:request(Config, "TrentService.ListAliases", Json).


%%%------------------------------------------------------------------------------
%%% ListGrants
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_ListGrants.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec list_grants/1 ::
          (KeyId :: string()) ->
          any().
list_grants(KeyId) ->
    list_grants(KeyId, []).


-spec list_grants/2 ::
          (KeyId :: string(),
           Options :: pagination_opts()) ->
          any().
list_grants(KeyId, Options) ->
    list_grants(KeyId, Options, default_config()).


-spec list_grants/3 ::
          (KeyId :: string(),
           Options :: pagination_opts(),
           Config :: aws_config()) ->
          any().
list_grants(KeyId, Options, Config) ->
    OptJson = dynamize_options(Options),
    Json = [{<<"KeyId">>, KeyId}|OptJson],
    erlcloud_kms_impl:request(Config, "TrentService.ListGrants", Json).


%%%------------------------------------------------------------------------------
%%% ListKeyPolicies
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_ListKeyPolicies.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec list_key_policies/1 ::
          (KeyId :: string()) ->
          any().
list_key_policies(KeyId) ->
    list_key_policies(KeyId, []).


-spec list_key_policies/2 ::
          (KeyId :: string(),
           Options :: pagination_opts()) ->
          any().
list_key_policies(KeyId, Options) ->
    list_key_policies(KeyId, Options, default_config()).


-spec list_key_policies/3 ::
          (KeyId :: string(),
           Options :: pagination_opts(),
           Config :: aws_config()) ->
          any().
list_key_policies(KeyId, Options, Config) ->
    OptJson = dynamize_options(Options),
    Json = [{<<"KeyId">>, KeyId}|OptJson],
    erlcloud_kms_impl:request(Config, "TrentService.ListKeyPolicies", Json).


%%%------------------------------------------------------------------------------
%%% ListKeys
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_ListKeys.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec list_keys/0 ::
          () ->
          any().
list_keys() ->
    list_keys([]).


-spec list_keys/1 ::
          (Options :: pagination_opts()) ->
          any().
list_keys(Options) ->
    list_keys(Options, default_config()).


-spec list_keys/2 ::
          (Options :: pagination_opts(),
           Config :: aws_config()) ->
          any().
list_keys(Options, Config) ->
    Json = dynamize_options(Options),
    erlcloud_kms_impl:request(Config, "TrentService.ListKeys", Json).


%%%------------------------------------------------------------------------------
%%% PutKeyPolicy
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_PutKeyPolicy.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec put_key_policy/3 ::
          (KeyId :: string(),
           Policy :: string(),
           PolicyName :: string()) ->
          any().
put_key_policy(KeyId, Policy, PolicyName) ->
    put_key_policy(KeyId, Policy, PolicyName, default_config()).


-spec put_key_policy/4 ::
          (KeyId :: string(),
           Policy :: string(),
           PolicyName :: string(),
           Config :: aws_config()) ->
          any().
put_key_policy(KeyId, Policy, PolicyName, Config) ->
    Json = [{<<"KeyId">>, KeyId}, {<<"Policy">>, Policy}, {<<"PolicyName">>, PolicyName}],
    erlcloud_kms_impl:request(Config, "TrentService.PutKeyPolicy", Json).


%%%------------------------------------------------------------------------------
%%% ReEncrypt
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_ReEncrypt.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-type re_encrypt_opts() :: [re_encrypt_opt()].
-type re_encrypt_opt() :: {re_encrypt_opt_key(), term()}.
-type re_encrypt_opt_key() :: destination_encryption_context | grant_tokens | source_encryption_context.


-spec re_encrypt/2 ::
          (CiphertextBlob :: string(),
           DestinationKeyId :: string()) ->
          any().
re_encrypt(CiphertextBlob, DestinationKeyId) ->
    re_encrypt(CiphertextBlob, DestinationKeyId, []).


-spec re_encrypt/3 ::
          (CiphertextBlob :: string(),
           DestinationKeyId :: string(),
           Options :: re_encrypt_opts()) ->
          any().
re_encrypt(CiphertextBlob, DestinationKeyId, Options) ->
    re_encrypt(CiphertextBlob, DestinationKeyId, Options, default_config()).


-spec re_encrypt/4 ::
          (CiphertextBlob :: string(),
           DestinationKeyId :: string(),
           Options :: re_encrypt_opts(),
           Config :: aws_config()) ->
          any().
re_encrypt(CiphertextBlob, DestinationKeyId, Options, Config) ->
    OptJson = dynamize_options(Options),
    Json = [{<<"CiphertextBlob">>, CiphertextBlob}, {<<"DestinationKeyId">>, DestinationKeyId}|OptJson],
    erlcloud_kms_impl:request(Config, "TrentService.ReEncrypt", Json).


%%%------------------------------------------------------------------------------
%%% RetireGrant
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_RetireGrant.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-type retire_grant_opts() :: [retire_grant_opt()].
-type retire_grant_opt() :: {retire_grant_opt_key(), term()}.
-type retire_grant_opt_key() :: key_id | grant_id | grant_token.

-spec retire_grant/1 ::
          (Options :: retire_grant_opts()) ->
          any().
retire_grant(Options) ->
    retire_grant(Options, default_config()).


-spec retire_grant/2 ::
          (Options :: retire_grant_opts(),
           Config :: aws_config()) ->
          any().
retire_grant(Options, Config) ->
    Json = dynamize_options(Options),
    erlcloud_kms_impl:request(Config, "TrentService.RetireGrant", Json).


%%%------------------------------------------------------------------------------
%%% RevokeGrant
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_RevokeGrant.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec revoke_grant/2 ::
          (GrantId :: string(),
           KeyId :: string()) ->
          any().
revoke_grant(GrantId, KeyId) ->
    revoke_grant(GrantId, KeyId, default_config()).


-spec revoke_grant/3 ::
          (GrantId :: string(),
           KeyId :: string(),
           Config :: aws_config()) ->
          any().
revoke_grant(GrantId, KeyId, Config) ->
    Json = [{<<"GrantId">>, GrantId}, {<<"KeyId">>, KeyId}],
    erlcloud_kms_impl:request(Config, "TrentService.RevokeGrant", Json).

%%%------------------------------------------------------------------------------
%%% UpdateAlias
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_UpdateAlias.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec update_alias/2 ::
          (AliasName :: string(),
           TargetKeyId :: string()) -> any().
update_alias(AliasName, TargetKeyId) ->
    update_alias(AliasName, TargetKeyId, default_config()).


-spec update_alias/3 ::
          (AliasName :: string(),
           TargetKeyId :: string(),
           Config :: aws_config()) -> any().
update_alias(AliasName, TargetKeyId, Config) ->
    Json = [{<<"AliasName">>, AliasName}, {<<"TargetKeyId">>, TargetKeyId}],
    erlcloud_kms_impl:request(Config, "TrentService.UpdateAlias", Json).


%%%------------------------------------------------------------------------------
%%% UpdateKeyDescription
%%%------------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%% @doc
%% KMS API:
%% [http://docs.aws.amazon.com/kms/latest/APIReference/API_UpdateKeyDescription.html]
%%
%% ===Example===
%%
%%------------------------------------------------------------------------------
-spec update_key_description/2 ::
          (KeyId :: string(),
           Description :: string()) ->
          any().
update_key_description(KeyId, Description) ->
    update_key_description(KeyId, Description, default_config()).


-spec update_key_description/3 ::
          (KeyId :: string(),
           Description :: string(),
           Config :: aws_config()) ->
          any().
update_key_description(KeyId, Description, Config) ->
    Json = [{<<"KeyId">>, KeyId}, {<<"Description">>, Description}],
    erlcloud_kms_impl:request(Config, "TrentService.UpdateKeyDescription", Json).


%
% Private
%
dynamize_options(List) ->
    dynamize_options(List, []).


dynamize_options([{Key, Value}|T], Acc) ->
    case dynamize_option_key(Key) of
        undefined -> dynamize_options(T, Acc);
        DynamizedKey -> dynamize_options(T, [{DynamizedKey, Value}|Acc])
    end;
dynamize_options([], Acc) ->
    Acc.


dynamize_option_key(constraints) -> <<"Constraints">>;
dynamize_option_key(description) -> <<"Description">>;
dynamize_option_key(encryption_context) -> <<"EncryptionContext">>;
dynamize_option_key(grant_id) -> <<"KeySpec">>;
dynamize_option_key(grant_tokens) -> <<"GrantTokens">>;
dynamize_option_key(grantee_principal) -> <<"GranteePrincipal">>;
dynamize_option_key(key_id) -> <<"KeyId">>;
dynamize_option_key(key_spec) -> <<"KeySpec">>;
dynamize_option_key(key_usage) -> <<"KeyUsage">>;
dynamize_option_key(limit) -> <<"Limit">>;
dynamize_option_key(marker) -> <<"Marker">>;
dynamize_option_key(number_of_bytes) -> <<"NumberOfBytes">>;
dynamize_option_key(operations) -> <<"Operations">>;
dynamize_option_key(policy) -> <<"Policy">>;
dynamize_option_key(_) -> undefined.