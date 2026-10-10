-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema zomato_restaurante
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema zomato_restaurante
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `zomato_restaurante` DEFAULT CHARACTER SET utf8 ;
USE `zomato_restaurante` ;

-- -----------------------------------------------------
-- Table `zomato_restaurante`.`cocina`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `zomato_restaurante`.`cocina` (
  `id` INT(20) NOT NULL AUTO_INCREMENT,
  `nom` VARCHAR(80) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zomato_restaurante`.`resena_textual`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `zomato_restaurante`.`resena_textual` (
  `id_text` INT(20) NOT NULL AUTO_INCREMENT,
  `rat_text` VARCHAR(80) NOT NULL,
  PRIMARY KEY (`id_text`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zomato_restaurante`.`resena_color`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `zomato_restaurante`.`resena_color` (
  `id_color` INT(20) NOT NULL AUTO_INCREMENT,
  `rat_color` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id_color`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zomato_restaurante`.`codigopais`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `zomato_restaurante`.`codigopais` (
  `id` INT(20) NOT NULL AUTO_INCREMENT,
  `cod` INT(20) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zomato_restaurante`.`ciudad`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `zomato_restaurante`.`ciudad` (
  `id` INT(20) NOT NULL AUTO_INCREMENT,
  `nom` VARCHAR(80) NULL,
  `cod_id` INT(20) NULL,
  PRIMARY KEY (`id`),
  INDEX `cod_id_idx` (`cod_id` ) ,
  CONSTRAINT `cod_id`
    FOREIGN KEY (`cod_id`)
    REFERENCES `zomato_restaurante`.`codigopais` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zomato_restaurante`.`localidad`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `zomato_restaurante`.`localidad` (
  `id` INT(20) NOT NULL AUTO_INCREMENT,
  `loca` VARCHAR(200) NOT NULL,
  `loca_detallada` VARCHAR(200) NOT NULL,
  `id_ciudad` INT(20) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `id_ciudad_idx` (`id_ciudad` ) ,
  CONSTRAINT `id_ciudad`
    FOREIGN KEY (`id_ciudad`)
    REFERENCES `zomato_restaurante`.`ciudad` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zomato_restaurante`.`moneda`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `zomato_restaurante`.`moneda` (
  `id` INT(20) NOT NULL AUTO_INCREMENT,
  `moneda` VARCHAR(80) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zomato_restaurante`.`restaurante`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `zomato_restaurante`.`restaurante` (
  `id` INT(20) NOT NULL,
  `rest` VARCHAR(80) NOT NULL,
  `direccion` VARCHAR(80) NOT NULL,
  `long_latit` POINT NULL,
  `rating` FLOAT NOT NULL,
  `votos` INT(20) NOT NULL,
  `cost_med_pare` FLOAT NOT NULL,
  `permite_reserv` TINYINT NOT NULL,
  `tiene_deliver` TINYINT NOT NULL,
  `deliver_dispo` TINYINT NOT NULL,
  `tiene_cambio_menu` TINYINT NOT NULL,
  `resena_tex` INT(20) NOT NULL,
  `resena_co` INT(20) NOT NULL,
  `precio_med` INT(20) NOT NULL,
  `id_loca` INT(20) NOT NULL,
  `moneda_id` INT(20) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `resena_med_idx` (`resena_tex` ) ,
  INDEX `resena_med_idx1` (`resena_co` ) ,
  INDEX `loca_idx` (`id_loca` ) ,
  INDEX `fk_restaurante_moneda1_idx` (`moneda_id` ) ,
  CONSTRAINT `resena_tex`
    FOREIGN KEY (`resena_tex`)
    REFERENCES `zomato_restaurante`.`resena_textual` (`id_text`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `resena_co`
    FOREIGN KEY (`resena_co`)
    REFERENCES `zomato_restaurante`.`resena_color` (`id_color`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `id_loca`
    FOREIGN KEY (`id_loca`)
    REFERENCES `zomato_restaurante`.`localidad` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_restaurante_moneda1`
    FOREIGN KEY (`moneda_id`)
    REFERENCES `zomato_restaurante`.`moneda` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `zomato_restaurante`.`restaurante_cocina`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `zomato_restaurante`.`restaurante_cocina` (
  `id_rest` INT(20) NOT NULL,
  `id_cocina` INT(20) NOT NULL,
  PRIMARY KEY (`id_rest`, `id_cocina`),
  INDEX `id_cocina_idx` (`id_cocina` ) ,
  CONSTRAINT `id_rest`
    FOREIGN KEY (`id_rest`)
    REFERENCES `zomato_restaurante`.`restaurante` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `id_cocina`
    FOREIGN KEY (`id_cocina`)
    REFERENCES `zomato_restaurante`.`cocina` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
