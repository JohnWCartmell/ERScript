@echo off
SET DISTRIBUTION=%1
SET ERHOME=%2

call %~dp0\set_build_path_variables

echo Generating ERmodel.svg
call %~dp0\generate_logical_svgandlog

echo Generating physical data model and the XML schema (ERmodel.rng)
call %~dp0\generate_physical_modelandlog

echo validating the meta model is as instance of itself
call %~dp0\validate_logical_model

echo validating the phsyical meta model is an instance of itself
call %~dp0\validate_physical_model