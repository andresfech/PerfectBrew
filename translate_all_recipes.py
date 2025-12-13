#!/usr/bin/env python3
"""
translate_all_recipes.py

Generates complete Spanish translations for ALL recipe JSON files.
Injects _es fields directly into each recipe.

Usage:
    python3 translate_all_recipes.py
"""

import json
import os
import re

RECIPES_DIR = "PerfectBrew/Resources/Recipes"

# ============================================================================
# SPANISH TRANSLATION DICTIONARIES
# ============================================================================

# Common brewing terms
TERMS = {
    "Pour": "Vierte",
    "Stir": "Revuelve",
    "Wait": "Espera",
    "Press": "Presiona",
    "Bloom": "Bloom",
    "Flip": "Voltea",
    "Swirl": "Agita circularmente",
    "hot water": "agua caliente",
    "coffee": "café",
    "grounds": "molido",
    "filter": "filtro",
    "plunger": "émbolo",
    "timer": "cronómetro",
    "scale": "báscula",
    "kettle": "hervidor",
    "seconds": "segundos",
    "minutes": "minutos",
    "grams": "gramos",
    "water": "agua",
    "AeroPress": "AeroPress",
    "V60": "V60",
    "French Press": "Prensa Francesa",
    "Chemex": "Chemex",
    "inverted": "invertido",
    "standard": "estándar",
    "grind": "molienda",
    "coarse": "gruesa",
    "fine": "fina",
    "medium": "media",
    "temperature": "temperatura",
    "extraction": "extracción",
    "steep": "reposar",
    "brew": "preparar",
}

# Full recipe translations - organized by file key
TRANSLATIONS = {
    # ========== AEROPRESS ==========
    "AeroPress_Championship_Concentrate_single_serve": {
        "title_es": "AeroPress Concentrado de Campeonato",
        "notes_es": "Método de competición de alta concentración: 20g/100g, 94°C, molienda fina, agitación controlada (~10s), ~60-70s de reposo antes de voltear y 20-30s de presión. Diluir al gusto o usar como base para bebidas con leche.",
        "preparation_steps_es": [
            "Enjuaga un filtro de papel bajo agua caliente y colócalo en la tapa del AeroPress (esto elimina el sabor a papel y precalienta la tapa).",
            "Ensambla el AeroPress en posición invertida (émbolo abajo, cámara abierta arriba) y colócalo en la báscula.",
            "Pesa 20g de café y muele a consistencia fina, similar a filtro (ligeramente más fina que filtro típico).",
            "Hierve agua y deja reposar ~5-10s (usa ~94°C). Ten báscula y cronómetro listos."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Inicia el cronómetro, tara la báscula y vierte 100g de agua caliente uniformemente sobre el molido.",
                "short_instruction_es": "Vierte 100g de agua caliente uniformemente",
                "audio_script_es": "En 10 segundos, deberías haber vertido toda el agua. Inicia tu cronómetro, tara la báscula a cero, y comienza a verter 100 gramos de agua caliente uniformemente sobre el café molido. Vierte en movimiento circular constante para asegurar saturación completa."
            },
            {
                "instruction_es": "Revuelve vigorosamente durante ~10 segundos para asegurar saturación completa y extracción uniforme.",
                "short_instruction_es": "Revuelve vigorosamente • 10 segundos",
                "audio_script_es": "En 10 segundos, deberías haber terminado de revolver. Ahora revuelve vigorosamente durante unos 10 segundos para asegurar saturación completa y extracción uniforme. Usa una cuchara o paleta para mezclar el café y el agua completamente."
            },
            {
                "instruction_es": "Rápidamente limpia cualquier gota, enrosca la tapa con el filtro enjuagado y espera (mantén invertido).",
                "short_instruction_es": "Limpia gotas • Enrosca la tapa del filtro",
                "audio_script_es": "En 10 segundos, deberías tener la tapa del filtro puesta. Rápidamente limpia cualquier gota de la cámara del AeroPress, luego enrosca la tapa con el filtro enjuagado. Mantén el AeroPress invertido y espera al siguiente paso."
            },
            {
                "instruction_es": "Deja reposar hasta ~1:20 en el cronómetro (reposo total ≈ 60-70s después de revolver).",
                "short_instruction_es": "Deja reposar • Hasta 1:20",
                "audio_script_es": "Tienes 60 segundos para completar este paso. Deja que el café repose hasta que el cronómetro marque 1:20. Esto le da al café aproximadamente 60 a 70 segundos de tiempo de reposo total después de revolver, permitiendo una extracción adecuada."
            },
            {
                "instruction_es": "Voltea cuidadosamente el AeroPress sobre tu taza/servidor y presiona constantemente; apunta a 20-30s de presión hasta que esté completamente presionado.",
                "short_instruction_es": "Voltea AeroPress • Presiona 20-30 segundos",
                "audio_script_es": "En 30 segundos, deberías haber terminado de presionar. Voltea cuidadosamente el AeroPress sobre tu taza o servidor y comienza a presionar constantemente. Apunta a un tiempo de presión de 20 a 30 segundos hasta que el émbolo esté completamente presionado."
            }
        ],
        "what_to_expect": {
            "description_es": "Método de competición de alta concentración que produce un café intenso y con cuerpo completo. La proporción 1:5, molienda fina, y agitación controlada crean un concentrado rico que puede diluirse al gusto o usarse como base para bebidas con leche. Espera sabores intensos, complejos y un cuerpo denso.",
            "audio_script_es": "Este es un método de competición de alta concentración. Usamos una proporción de 1:5 con molienda fina y agitación controlada para crear un concentrado rico e intenso. Puedes diluirlo al gusto o usarlo como base para bebidas con leche."
        }
    },
    "AeroPress_Single_Cup_of_Joy_single_serve": {
        "title_es": "AeroPress Taza de Alegría",
        "notes_es": "Una receta sencilla y reconfortante para el día a día. Equilibrada, accesible y perfecta para cualquier tipo de café.",
        "preparation_steps_es": [
            "Enjuaga el filtro de papel con agua caliente.",
            "Ensambla el AeroPress en posición estándar sobre tu taza.",
            "Muele 15g de café a molienda media.",
            "Calienta el agua a 92°C."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte 50g de agua y deja florecer 30 segundos.",
                "short_instruction_es": "Bloom 50g • 30 segundos",
                "audio_script_es": "Vierte 50 gramos de agua caliente sobre el café molido. Deja que haga bloom durante 30 segundos. Esto permite que el café libere CO2 y se prepare para una extracción uniforme."
            },
            {
                "instruction_es": "Vierte el resto del agua hasta llegar a 220g total.",
                "short_instruction_es": "Vierte hasta 220g total",
                "audio_script_es": "Ahora vierte el resto del agua hasta alcanzar 220 gramos totales. Vierte en movimiento circular lento para una extracción uniforme."
            },
            {
                "instruction_es": "Revuelve suavemente 3 veces y coloca el émbolo para crear sello.",
                "short_instruction_es": "Revuelve 3 veces • Sella",
                "audio_script_es": "Revuelve suavemente 3 veces con una cuchara, luego coloca el émbolo para crear un sello de vacío que evita goteo."
            },
            {
                "instruction_es": "Espera hasta 1:30 y presiona lentamente durante 30 segundos.",
                "short_instruction_es": "Espera hasta 1:30 • Presiona 30s",
                "audio_script_es": "Espera hasta que el cronómetro marque 1 minuto 30 segundos, luego presiona lenta y constantemente durante 30 segundos. Detente cuando escuches el silbido."
            }
        ],
        "what_to_expect": {
            "description_es": "Una taza equilibrada y reconfortante perfecta para el día a día. Esta receta es accesible para principiantes y produce resultados consistentes con cualquier tipo de café.",
            "audio_script_es": "Esta receta produce una taza equilibrada y reconfortante. Es perfecta para principiantes y funciona bien con cualquier tipo de café. Espera un sabor suave, dulce y sin complicaciones."
        }
    },
    "AeroPress_10g_Gentle_Steep": {
        "title_es": "AeroPress Reposo Suave 10g",
        "notes_es": "Excelente para cafés lavados florales o frutales.",
        "preparation_steps_es": [
            "Muele 10g de café grueso (como prensa francesa).",
            "Ensambla el AeroPress estándar o invertido (estándar está bien si insertas el émbolo).",
            "Calienta el agua a 98°C (justo después de hervir)."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte 200g de agua vigorosamente.",
                "short_instruction_es": "Vierte 200g",
                "audio_script_es": "Vierte 200 gramos de agua vigorosamente para agitar el molido. Estamos usando agua hirviendo y molienda gruesa para una extracción muy larga."
            },
            {
                "instruction_es": "Inserta el émbolo ligeramente para detener el goteo.",
                "short_instruction_es": "Sello de vacío",
                "audio_script_es": "Inserta el émbolo apenas en la parte superior de la cámara. Esto crea un sello de vacío y evita que el café gotee. Ahora, esperamos."
            },
            {
                "instruction_es": "Espera hasta 4:00. Luego presiona.",
                "short_instruction_es": "Espera 4 mins • Presiona",
                "audio_script_es": "Deja reposar durante 4 minutos completos. Este largo tiempo de contacto con molienda gruesa extrae dulzura sin amargor. A los 4 minutos, presiona suavemente."
            }
        ],
        "what_to_expect": {
            "description_es": "Inspirado en protocolos de catación, este método usa molienda gruesa y un tiempo de reposo largo de 4 minutos. El resultado es un cuerpo increíblemente limpio, similar al té, con alta dulzura y claridad. La proporción 1:20 lo hace ligero y delicado.",
            "audio_script_es": "Este método imita el proceso de catación de café. Usando molienda gruesa y un tiempo de reposo muy largo de 4 minutos, obtenemos una taza delicada, similar al té. Es imposible sobre-extraer de esta manera, así que obtendrás máxima dulzura y claridad."
        }
    },
    "AeroPress_11g_Espresso_Style": {
        "title_es": "AeroPress Estilo Espresso 11g",
        "notes_es": "Concentrado que imita el espresso. Ideal para lattes o consumir solo si te gusta el café fuerte.",
        "preparation_steps_es": [
            "Muele 11g de café muy fino (casi espresso).",
            "Ensambla el AeroPress invertido.",
            "Calienta el agua a 92°C.",
            "Ten lista una taza pequeña."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte 50g de agua rápidamente.",
                "short_instruction_es": "Vierte 50g rápido",
                "audio_script_es": "Vierte 50 gramos de agua caliente rápidamente sobre el café. La baja cantidad de agua creará un concentrado intenso."
            },
            {
                "instruction_es": "Revuelve vigorosamente 15 veces.",
                "short_instruction_es": "Revuelve 15 veces",
                "audio_script_es": "Revuelve vigorosamente 15 veces. Esta agitación intensa es necesaria para extraer el máximo de sabor en poco tiempo."
            },
            {
                "instruction_es": "Espera 30 segundos, luego presiona fuerte durante 20 segundos.",
                "short_instruction_es": "Espera 30s • Presiona fuerte 20s",
                "audio_script_es": "Espera 30 segundos, luego presiona con fuerza durante 20 segundos. La presión fuerte es clave para este método estilo espresso."
            }
        ],
        "what_to_expect": {
            "description_es": "Un concentrado estilo espresso con cuerpo denso y sabores intensos. Perfecto para agregar leche caliente y crear un latte casero o beber solo si prefieres café fuerte.",
            "audio_script_es": "Este método crea un concentrado similar al espresso. La molienda muy fina, poca agua y presión fuerte producen un shot intenso. Perfecto para lattes o para quienes aman el café fuerte."
        }
    },
    "AeroPress_12g_Everyday_Inverted": {
        "title_es": "AeroPress Invertido Diario 12g",
        "notes_es": "Receta versátil para el día a día. Funciona con todo tipo de cafés.",
        "preparation_steps_es": [
            "Muele 12g de café a molienda media-fina.",
            "Ensambla el AeroPress en posición invertida.",
            "Calienta el agua a 94°C."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte 200g de agua en 15 segundos.",
                "short_instruction_es": "Vierte 200g • 15 segundos",
                "audio_script_es": "Vierte 200 gramos de agua caliente durante 15 segundos. Asegúrate de mojar todo el café uniformemente."
            },
            {
                "instruction_es": "Revuelve suavemente 5 veces.",
                "short_instruction_es": "Revuelve 5 veces",
                "audio_script_es": "Revuelve suavemente 5 veces para asegurar una extracción uniforme. No agites demasiado."
            },
            {
                "instruction_es": "Espera hasta 1:30 en total.",
                "short_instruction_es": "Espera hasta 1:30",
                "audio_script_es": "Deja que el café repose hasta que el cronómetro marque 1 minuto 30 segundos."
            },
            {
                "instruction_es": "Coloca la tapa, voltea y presiona durante 30 segundos.",
                "short_instruction_es": "Tapa • Voltea • Presiona 30s",
                "audio_script_es": "Coloca la tapa con el filtro, voltea sobre tu taza y presiona lenta y constantemente durante 30 segundos."
            }
        ],
        "what_to_expect": {
            "description_es": "Una receta versátil perfecta para el uso diario. Produce una taza equilibrada con buen cuerpo y claridad. Funciona bien con todo tipo de cafés.",
            "audio_script_es": "Esta es una receta versátil para el día a día. Produce una taza equilibrada que funciona con cualquier tipo de café. Espera buen cuerpo y claridad."
        }
    },
    "AeroPress_13_5g_Strength_Focus": {
        "title_es": "AeroPress Enfoque en Fuerza 13.5g",
        "notes_es": "Para quienes prefieren un café más fuerte sin llegar a ser un concentrado.",
        "preparation_steps_es": [
            "Muele 13.5g de café a molienda media.",
            "Ensambla el AeroPress en posición estándar.",
            "Calienta el agua a 96°C."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte 40g de agua para bloom, espera 30 segundos.",
                "short_instruction_es": "Bloom 40g • 30 segundos",
                "audio_script_es": "Vierte 40 gramos de agua caliente para el bloom. Espera 30 segundos mientras el café libera gases."
            },
            {
                "instruction_es": "Vierte hasta 200g total lentamente.",
                "short_instruction_es": "Vierte hasta 200g total",
                "audio_script_es": "Vierte lentamente el resto del agua hasta alcanzar 200 gramos totales. Mantén un flujo constante y circular."
            },
            {
                "instruction_es": "Inserta émbolo para sellar, espera hasta 2:00.",
                "short_instruction_es": "Sella • Espera hasta 2:00",
                "audio_script_es": "Inserta el émbolo para crear un sello y espera hasta que el cronómetro marque 2 minutos."
            },
            {
                "instruction_es": "Presiona lentamente durante 30 segundos.",
                "short_instruction_es": "Presiona 30 segundos",
                "audio_script_es": "Presiona lenta y constantemente durante 30 segundos. Detente cuando escuches el silbido suave."
            }
        ],
        "what_to_expect": {
            "description_es": "Una taza más fuerte que el promedio sin ser un concentrado. Buen cuerpo y sabores pronunciados. Ideal para quienes encuentran otras recetas demasiado suaves.",
            "audio_script_es": "Esta receta está diseñada para quienes prefieren café más fuerte. No es un concentrado, pero tiene más cuerpo e intensidad que la mayoría de las recetas."
        }
    },
    "AeroPress_14g_Bypass_Americano": {
        "title_es": "AeroPress Americano con Bypass 14g",
        "notes_es": "Produce un concentrado que se diluye con agua caliente, similar a un Americano.",
        "preparation_steps_es": [
            "Muele 14g de café a molienda fina.",
            "Ensambla el AeroPress invertido.",
            "Calienta el agua a 94°C.",
            "Ten 100g de agua caliente adicional lista para el bypass."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte 100g de agua y revuelve 5 veces.",
                "short_instruction_es": "Vierte 100g • Revuelve 5 veces",
                "audio_script_es": "Vierte 100 gramos de agua caliente y revuelve inmediatamente 5 veces. Esto crea el concentrado base."
            },
            {
                "instruction_es": "Espera 1 minuto con el émbolo insertado.",
                "short_instruction_es": "Espera 1 minuto • Émbolo sellando",
                "audio_script_es": "Inserta el émbolo para sellar y espera 1 minuto completo."
            },
            {
                "instruction_es": "Voltea y presiona durante 20 segundos.",
                "short_instruction_es": "Voltea • Presiona 20s",
                "audio_script_es": "Voltea sobre tu taza y presiona durante 20 segundos. Este es tu concentrado."
            },
            {
                "instruction_es": "Agrega 100g de agua caliente (bypass).",
                "short_instruction_es": "Añade 100g agua caliente",
                "audio_script_es": "Agrega 100 gramos de agua caliente para diluir el concentrado. Esto te da un Americano equilibrado."
            }
        ],
        "what_to_expect": {
            "description_es": "Un Americano casero usando la técnica de bypass. El concentrado diluido produce una taza limpia y equilibrada con el volumen de un café filtrado tradicional.",
            "audio_script_es": "Esta receta crea un Americano casero. Primero extraemos un concentrado, luego lo diluimos con agua caliente. El resultado es una taza limpia con el volumen de un café filtrado normal."
        }
    },
    "AeroPress_Alan_Adler_Original_14g": {
        "title_es": "AeroPress Original de Alan Adler 14g",
        "notes_es": "La receta original del inventor del AeroPress. Simple, rápida y confiable.",
        "preparation_steps_es": [
            "Muele 14g de café a molienda fina.",
            "Ensambla el AeroPress en posición estándar.",
            "Calienta el agua a 80°C (más baja que la mayoría de recetas)."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte 200g de agua rápidamente.",
                "short_instruction_es": "Vierte 200g rápido",
                "audio_script_es": "Vierte 200 gramos de agua caliente rápidamente sobre el café. Alan Adler recomienda temperatura más baja para evitar amargor."
            },
            {
                "instruction_es": "Revuelve 10 segundos.",
                "short_instruction_es": "Revuelve 10 segundos",
                "audio_script_es": "Revuelve durante 10 segundos para asegurar extracción completa."
            },
            {
                "instruction_es": "Presiona inmediatamente durante 20-30 segundos.",
                "short_instruction_es": "Presiona inmediatamente • 20-30s",
                "audio_script_es": "Presiona inmediatamente durante 20 a 30 segundos. Esta receta es rápida - sin tiempo de reposo prolongado."
            }
        ],
        "what_to_expect": {
            "description_es": "La receta original del inventor del AeroPress, Alan Adler. Usa temperatura baja (80°C) para evitar amargor y un proceso rápido para producir una taza suave y agradable en menos de un minuto.",
            "audio_script_es": "Esta es la receta original del inventor del AeroPress. Alan Adler usa agua a temperatura más baja que la mayoría para evitar amargor. Es simple, rápida y produce una taza suave cada vez."
        }
    },
    "AeroPress_2021_Tuomas_Merikanto_single_serve": {
        "title_es": "Campeón Mundial AeroPress 2021 - Tuomas Merikanto (Finlandia)",
        "notes_es": "Receta ganadora del Campeonato Mundial de AeroPress 2021. Enfocada en claridad y delicadeza con método invertido y bypass.",
        "preparation_steps_es": [
            "Enjuaga el filtro de papel con agua caliente.",
            "Ensambla el AeroPress en posición invertida.",
            "Muele 16g de café a molienda medio-gruesa.",
            "Calienta el agua a 93°C."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte 60g de agua para bloom durante 30 segundos.",
                "short_instruction_es": "Bloom 60g • 30 segundos",
                "audio_script_es": "Vierte 60 gramos de agua caliente para el bloom. Deja reposar 30 segundos mientras el café libera CO2."
            },
            {
                "instruction_es": "Vierte hasta 100g total y revuelve suavemente 3 veces.",
                "short_instruction_es": "Vierte hasta 100g • Revuelve 3 veces",
                "audio_script_es": "Vierte más agua hasta alcanzar 100 gramos totales. Revuelve suavemente 3 veces para homogeneizar."
            },
            {
                "instruction_es": "Espera hasta 1:30, luego voltea y presiona durante 30 segundos.",
                "short_instruction_es": "Espera hasta 1:30 • Voltea • Presiona 30s",
                "audio_script_es": "Espera hasta el minuto 1:30, luego coloca la tapa, voltea y presiona lentamente durante 30 segundos."
            },
            {
                "instruction_es": "Agrega 100g de agua caliente para diluir.",
                "short_instruction_es": "Bypass 100g agua caliente",
                "audio_script_es": "Agrega 100 gramos de agua caliente para diluir el concentrado. Esto abre los sabores y crea una taza más limpia."
            }
        ],
        "what_to_expect": {
            "description_es": "La receta ganadora del Campeonato Mundial AeroPress 2021 de Tuomas Merikanto. Combina un concentrado suave con dilución por bypass para máxima claridad y sabores delicados.",
            "audio_script_es": "Esta es la receta campeona mundial de 2021. Tuomas Merikanto crea un concentrado suave que luego diluye con agua caliente. El resultado es una taza increíblemente limpia y delicada."
        }
    },
    "AeroPress_2022_Jibbi_Little_single_serve": {
        "title_es": "Campeona Mundial AeroPress 2022 - Jibbi Little (Australia) - Hielos",
        "notes_es": "Receta ganadora del Campeonato Mundial de AeroPress 2022. Método único que usa hielos para enfriar rápidamente y fijar sabores delicados.",
        "preparation_steps_es": [
            "Enjuaga el filtro de papel con agua caliente.",
            "Ensambla el AeroPress en posición invertida.",
            "Muele 20g de café a molienda media.",
            "Calienta el agua a 96°C.",
            "Prepara hielos en tu servidor."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte 60g de agua para bloom durante 30 segundos.",
                "short_instruction_es": "Bloom 60g • 30 segundos",
                "audio_script_es": "Vierte 60 gramos de agua para el bloom. El café fresco liberará muchos gases - déjalo respirar 30 segundos."
            },
            {
                "instruction_es": "Vierte hasta 100g total, revuelve vigorosamente.",
                "short_instruction_es": "Vierte hasta 100g • Revuelve vigoroso",
                "audio_script_es": "Vierte hasta 100 gramos totales y revuelve vigorosamente. Queremos máxima extracción para compensar la dilución con hielo."
            },
            {
                "instruction_es": "Espera hasta 1:15, voltea y presiona sobre los hielos durante 30 segundos.",
                "short_instruction_es": "Espera 1:15 • Voltea • Presiona sobre hielos",
                "audio_script_es": "Al minuto 1:15, coloca la tapa, voltea sobre el servidor con hielos y presiona durante 30 segundos. El café caliente golpeará los hielos y se enfriará instantáneamente."
            },
            {
                "instruction_es": "Agita para derretir los hielos y mezclar.",
                "short_instruction_es": "Agita para mezclar",
                "audio_script_es": "Agita el servidor para derretir completamente los hielos y mezclar todo. Esto fija los sabores más delicados que se perderían con enfriamiento lento."
            }
        ],
        "what_to_expect": {
            "description_es": "La innovadora receta ganadora de Jibbi Little usa hielos para enfriar instantáneamente el café, preservando aromas y sabores delicados que normalmente se pierden. Resulta en una taza refrescante con sabores brillantes y cristalinos.",
            "audio_script_es": "Esta receta campeona usa una técnica japonesa de enfriamiento rápido con hielos. Al enfriar el café instantáneamente, preservamos aromas delicados que normalmente se evaporarían. El resultado es una taza fría con sabores brillantes y cristalinos."
        }
    },
    "AeroPress_2023_Tay_Wipvasutt_single_serve": {
        "title_es": "Campeón Mundial AeroPress 2023 - Tay Wipvasutt (Tailandia)",
        "notes_es": "Receta ganadora del Campeonato Mundial de AeroPress 2023. Método meticuloso con múltiples vertidos y bypass frío.",
        "preparation_steps_es": [
            "Enjuaga el filtro de papel con agua caliente.",
            "Ensambla el AeroPress en posición invertida.",
            "Muele 18g de café a molienda medio-fina.",
            "Prepara agua a 92°C y agua a temperatura ambiente."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte 40g de agua para bloom durante 20 segundos.",
                "short_instruction_es": "Bloom 40g • 20 segundos",
                "audio_script_es": "Vierte 40 gramos de agua caliente para iniciar el bloom. Espera 20 segundos para la desgasificación."
            },
            {
                "instruction_es": "Vierte hasta 90g total, revuelve 3 veces.",
                "short_instruction_es": "Vierte hasta 90g • Revuelve 3 veces",
                "audio_script_es": "Vierte hasta 90 gramos totales y revuelve 3 veces para homogeneizar la extracción."
            },
            {
                "instruction_es": "Espera hasta 1:00, voltea y presiona durante 40 segundos.",
                "short_instruction_es": "Espera hasta 1:00 • Voltea • Presiona 40s",
                "audio_script_es": "Espera hasta el minuto 1, luego voltea y presiona lentamente durante 40 segundos. La presión lenta es clave."
            },
            {
                "instruction_es": "Agrega 60g de agua a temperatura ambiente.",
                "short_instruction_es": "Bypass 60g agua ambiente",
                "audio_script_es": "Agrega 60 gramos de agua a temperatura ambiente. Este bypass frío equilibra la temperatura y abre sabores sutiles."
            }
        ],
        "what_to_expect": {
            "description_es": "La receta ganadora de Tay Wipvasutt enfatiza el control de temperatura con un bypass de agua fría. Produce una taza compleja y equilibrada con excelente claridad y temperatura de servicio perfecta.",
            "audio_script_es": "El método de Tay Wipvasutt usa bypass con agua fría para controlar la temperatura final y abrir sabores sutiles. El resultado es una taza compleja, equilibrada y a la temperatura perfecta para beber inmediatamente."
        }
    },
    "AeroPress_2024_George_Stanica_single_serve": {
        "title_es": "Campeón Mundial AeroPress 2024 - George Stanica (Rumania) - Invertido",
        "notes_es": "Receta ganadora del Campeonato Mundial de AeroPress 2024. Enfatiza precisión y claridad con Melodrip y bypass de dos temperaturas.",
        "preparation_steps_es": [
            "Enjuaga un filtro de papel Aesir con agua caliente y colócalo en la tapa (elimina sabor a papel).",
            "Ensambla el AeroPress en posición invertida y alinea aproximadamente con la marca 4.",
            "Pesa 18g de café y muele a medio-grueso (Comandante C40 Mk4, ~58 clicks / ~870 µm).",
            "Añade los 18g de café al AeroPress invertido y agita suavemente para nivelar la cama.",
            "Prepara agua de extracción (96°C) y un Melodrip (o similar) para vertidos controlados. Ten báscula y cronómetro listos."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte 50g de agua a 96°C usando el Melodrip (apunta a 5-6s para el vertido). Permite que el café florezca.",
                "short_instruction_es": "Vierte 50g a 96°C • Bloom",
                "audio_script_es": "Inicia el cronómetro y vierte 50 gramos de agua rápidamente. Este primer vertido inicia el bloom, liberando dióxido de carbono y preparando la cama para extracción uniforme. Deja que burbujee y desgasifique."
            },
            {
                "instruction_es": "Vierte los segundos 50g de agua a 96°C (nuevamente ~5-6s de vertido).",
                "short_instruction_es": "Vierte segundos 50g de agua",
                "audio_script_es": "Ahora vierte los segundos 50 gramos de agua. Este vertido dividido ayuda a controlar la temperatura de la mezcla."
            },
            {
                "instruction_es": "Revuelve suavemente en patrón Norte-Sur-Este-Oeste (NSEO) durante ~10s. Luego espera hasta 1:05.",
                "short_instruction_es": "Revuelve patrón NSEO • Espera",
                "audio_script_es": "Revuelve suavemente en patrón Norte, Sur, Este, Oeste. Esto homogeneiza la mezcla, asegurando que cada partícula interactúe uniformemente con el agua."
            },
            {
                "instruction_es": "Enrosca la tapa enjuagada y presiona suavemente para remover el exceso de aire (~10s).",
                "short_instruction_es": "Enrosca tapa • Saca el aire",
                "audio_script_es": "Enrosca la tapa y presiona suavemente para sacar el exceso de aire. Esto crea un sello de vacío para evitar goteo cuando volteemos."
            },
            {
                "instruction_es": "Agita suavemente, coloca sobre el servidor y presiona (30-40s). Rendimiento objetivo: ~76-79g.",
                "short_instruction_es": "Agita • Voltea • Presiona 30-40s",
                "audio_script_es": "Agita suavemente para atrapar el molido de los lados, luego voltea sobre tu servidor. Presiona constantemente durante 30 a 40 segundos. Queremos una expresión lenta y controlada de sabor, no prisa."
            },
            {
                "instruction_es": "Agrega agua tibia hasta que el peso total alcance 130-135g (paso de bypass).",
                "short_instruction_es": "Añade agua tibia • Total 130-135g",
                "audio_script_es": "Agrega agua tibia hasta que el peso total alcance 135 gramos. Este bypass diluye el concentrado, abriendo el perfil de sabor."
            },
            {
                "instruction_es": "Agrega 20-30g adicionales de agua a temperatura ambiente de 0 ppm para equilibrio.",
                "short_instruction_es": "Añade agua ambiente • Equilibrio",
                "audio_script_es": "Finalmente, agrega 20 gramos de agua a temperatura ambiente. Esta técnica, llamada 'temperado', lleva el café a temperatura perfecta para beber inmediatamente."
            }
        ],
        "what_to_expect": {
            "description_es": "La receta del Campeón Mundial AeroPress 2024 de George Stanica enfatiza precisión y claridad. Dos vertidos controlados con Melodrip crean saturación uniforme, seguidos de revolvimiento suave NSEO y presión lenta para un concentrado limpio y estructurado. El equilibrio final se logra con bypass de agua tibia y un toque de agua a temperatura ambiente de 0 ppm. Espera claridad notable, dulzura refinada y una taza equilibrada y elegante que muestra el carácter de origen sin asperezas.",
            "audio_script_es": "Este método campeón de 2024 se enfoca en precisión y claridad. Usa dos vertidos controlados con Melodrip, revolvimiento suave NSEO, y presión lenta para producir un concentrado limpio. Termina con bypass de agua tibia y un toque de agua de 0 ppm para equilibrio. Espera claridad, dulzura refinada y una taza elegante."
        }
    },
    # ========== V60 ==========
    "V60_Scott_Rao_single_serve": {
        "title_es": "V60 de Scott Rao - Individual",
        "notes_es": "El método de Scott Rao enfatiza un bloom vigoroso y un solo vertido largo para máxima uniformidad.",
        "preparation_steps_es": [
            "Calienta el agua a 95-96°C.",
            "Muele 22g de café a molienda media.",
            "Enjuaga el filtro con agua caliente y descarta.",
            "Coloca el V60 sobre tu servidor."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Bloom con 60g de agua, excava el molido 5 veces para saturación completa. Espera 45 segundos.",
                "short_instruction_es": "Bloom 60g • Excava 5 veces • 45s",
                "audio_script_es": "Vierte 60 gramos de agua y usa una cuchara para excavar el molido 5 veces. Esto asegura que toda partícula esté saturada. Espera 45 segundos para el bloom completo."
            },
            {
                "instruction_es": "Vierte continuamente hasta 360g total en círculos concéntricos.",
                "short_instruction_es": "Vierte hasta 360g • Círculos",
                "audio_script_es": "Vierte agua continuamente en círculos concéntricos hasta alcanzar 360 gramos. Mantén el nivel del agua constante sin dejarlo drenar completamente."
            },
            {
                "instruction_es": "Agita el V60 suavemente para nivelar la cama de café.",
                "short_instruction_es": "Agita para nivelar",
                "audio_script_es": "Cuando termines de verter, agita suavemente el V60 con un movimiento circular. Esto nivela la cama de café para un drenaje uniforme."
            }
        ],
        "what_to_expect": {
            "description_es": "El método de Scott Rao produce una taza equilibrada y consistente. La técnica de excavar durante el bloom asegura saturación completa, mientras que el vertido continuo mantiene temperatura y extracción uniformes.",
            "audio_script_es": "El método de Scott Rao enfatiza la saturación completa durante el bloom y un vertido continuo. Esto produce una taza equilibrada con excelente consistencia cada vez."
        }
    },
    "V60_Kaldis_Coffee_single_serve": {
        "title_es": "V60 de Kaldi's Coffee - Individual",
        "notes_es": "Receta accesible de la cafetería Kaldi's. Simple y efectiva para el día a día.",
        "preparation_steps_es": [
            "Calienta el agua a 93°C.",
            "Muele 20g de café a molienda media.",
            "Enjuaga el filtro y precalienta el V60."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Bloom con 40g de agua durante 30 segundos.",
                "short_instruction_es": "Bloom 40g • 30 segundos",
                "audio_script_es": "Vierte 40 gramos de agua para el bloom. Espera 30 segundos para que el café libere gases."
            },
            {
                "instruction_es": "Vierte en pulsos de 60g cada 30 segundos hasta 300g total.",
                "short_instruction_es": "Pulsos de 60g cada 30s • Hasta 300g",
                "audio_script_es": "Vierte en pulsos de 60 gramos cada 30 segundos. Deja que el agua drene un poco entre cada pulso. Continúa hasta alcanzar 300 gramos totales."
            },
            {
                "instruction_es": "Espera el drenaje completo (~3 minutos total).",
                "short_instruction_es": "Espera drenaje • ~3 mins total",
                "audio_script_es": "Espera a que todo el agua drene. El tiempo total debería ser alrededor de 3 minutos."
            }
        ],
        "what_to_expect": {
            "description_es": "Una receta accesible y consistente perfecta para el uso diario. Los vertidos en pulso permiten control sobre la extracción sin complicar el proceso.",
            "audio_script_es": "Esta receta de Kaldi's Coffee es perfecta para principiantes. Los vertidos en pulso son fáciles de ejecutar y producen resultados consistentes cada día."
        }
    },
    "V60_Others_single_serve": {
        "title_es": "V60 Método Clásico - Individual",
        "notes_es": "Un método V60 tradicional y versátil que funciona con todo tipo de cafés.",
        "preparation_steps_es": [
            "Calienta el agua a 94°C.",
            "Muele 18g de café a molienda media-fina.",
            "Enjuaga el filtro con agua caliente."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Bloom con 36g de agua (2x café) durante 30 segundos.",
                "short_instruction_es": "Bloom 36g • 30 segundos",
                "audio_script_es": "Vierte 36 gramos de agua para el bloom, eso es el doble del peso del café. Espera 30 segundos."
            },
            {
                "instruction_es": "Vierte hasta 150g en círculos lentos.",
                "short_instruction_es": "Vierte hasta 150g • Círculos lentos",
                "audio_script_es": "Vierte lentamente en círculos hasta alcanzar 150 gramos. Mantén un flujo constante y controlado."
            },
            {
                "instruction_es": "Vierte hasta 280g total, termina en el centro.",
                "short_instruction_es": "Vierte hasta 280g • Termina al centro",
                "audio_script_es": "Continúa vertiendo hasta 280 gramos totales. Termina el último vertido en el centro del V60."
            }
        ],
        "what_to_expect": {
            "description_es": "Un método V60 clásico y versátil que produce una taza limpia y equilibrada. Funciona bien con todo tipo de cafés y es fácil de dominar.",
            "audio_script_es": "Este método V60 clásico es versátil y fácil de dominar. Produce una taza limpia y equilibrada con cualquier café."
        }
    },
    # V60 Small Batch recipes
    "V60_10g_Cafec_Slow": {
        "title_es": "V60 10g Método Cafec Lento",
        "notes_es": "Método de vertido muy lento inspirado en los filtros Cafec. Para quienes disfrutan un proceso meditativo.",
        "preparation_steps_es": [
            "Calienta el agua a 88°C (temperatura baja para extracción lenta).",
            "Muele 10g de café a molienda media-gruesa.",
            "Usa filtro Cafec o similar de drenaje lento."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Bloom con 25g de agua durante 45 segundos.",
                "short_instruction_es": "Bloom 25g • 45 segundos",
                "audio_script_es": "Vierte 25 gramos de agua para un bloom extendido. Espera 45 segundos completos para máxima desgasificación."
            },
            {
                "instruction_es": "Vierte muy lentamente hasta 160g en 2 minutos.",
                "short_instruction_es": "Vierte lento hasta 160g • 2 mins",
                "audio_script_es": "Vierte extremadamente lento hasta 160 gramos. Esto debería tomar 2 minutos completos. El flujo lento permite una extracción suave y dulce."
            }
        ],
        "what_to_expect": {
            "description_es": "Un método meditativo que produce una taza excepcionalmente dulce y suave. La temperatura baja y el vertido lento evitan cualquier amargor o aspereza.",
            "audio_script_es": "Este método lento inspirado en Cafec es para quienes disfrutan un proceso meditativo. La temperatura baja y el vertido extremadamente lento producen una taza dulce y suave sin ningún amargor."
        }
    },
    "V60_10g_Micro_Dose": {
        "title_es": "V60 10g Micro Dosis",
        "notes_es": "Porción pequeña para una sola taza concentrada. Ideal para probar cafés nuevos.",
        "preparation_steps_es": [
            "Calienta el agua a 96°C.",
            "Muele 10g de café a molienda media-fina.",
            "Usa V60 tamaño 01."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Bloom con 20g de agua durante 30 segundos.",
                "short_instruction_es": "Bloom 20g • 30 segundos",
                "audio_script_es": "Vierte 20 gramos para el bloom. Espera 30 segundos."
            },
            {
                "instruction_es": "Vierte hasta 150g total en un solo vertido lento.",
                "short_instruction_es": "Vierte hasta 150g • Un vertido",
                "audio_script_es": "Vierte lentamente hasta 150 gramos en un solo movimiento continuo. Mantén el flujo constante."
            }
        ],
        "what_to_expect": {
            "description_es": "Una porción pequeña perfecta para probar cafés nuevos sin comprometer una bolsa entera. Proporciona una evaluación clara del perfil de sabor.",
            "audio_script_es": "Esta micro dosis es perfecta para probar cafés nuevos. Con solo 10 gramos, puedes evaluar un café sin usar mucho de tu bolsa."
        }
    },
    "V60_10g_Slow_Pour_Single": {
        "title_es": "V60 10g Vertido Lento Individual",
        "notes_es": "Método de vertido único y lento para máxima claridad.",
        "preparation_steps_es": [
            "Calienta el agua a 92°C.",
            "Muele 10g de café a molienda media.",
            "Enjuaga el filtro."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Bloom con 20g de agua durante 35 segundos.",
                "short_instruction_es": "Bloom 20g • 35 segundos",
                "audio_script_es": "Vierte 20 gramos para el bloom y espera 35 segundos para desgasificación completa."
            },
            {
                "instruction_es": "Vierte muy lentamente hasta 170g total.",
                "short_instruction_es": "Vierte lento hasta 170g",
                "audio_script_es": "Vierte extremadamente lento hasta 170 gramos. El vertido lento produce una taza más limpia y clara."
            }
        ],
        "what_to_expect": {
            "description_es": "Un método simple que enfatiza la claridad. El vertido lento permite que cada partícula contribuya uniformemente a la taza final.",
            "audio_script_es": "Este método de vertido lento es simple pero efectivo. El flujo lento produce una taza limpia con excelente claridad."
        }
    },
    "V60_10g_Standard_Light_Roast": {
        "title_es": "V60 10g Estándar para Tueste Claro",
        "notes_es": "Optimizado para resaltar los sabores brillantes de tuestes claros.",
        "preparation_steps_es": [
            "Calienta el agua a 98°C (alta para tuestes claros).",
            "Muele 10g de café a molienda media-fina.",
            "Enjuaga el filtro con agua caliente."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Bloom con 25g de agua durante 30 segundos.",
                "short_instruction_es": "Bloom 25g • 30 segundos",
                "audio_script_es": "Vierte 25 gramos de agua caliente para el bloom. Los tuestes claros necesitan agua más caliente para extraer completamente."
            },
            {
                "instruction_es": "Vierte hasta 160g en círculos uniformes.",
                "short_instruction_es": "Vierte hasta 160g • Círculos",
                "audio_script_es": "Vierte en círculos uniformes hasta 160 gramos. La temperatura alta extraerá toda la acidez brillante y sabores frutales."
            }
        ],
        "what_to_expect": {
            "description_es": "Diseñado específicamente para tuestes claros. La temperatura alta extrae toda la acidez brillante y sabores frutales que hacen especiales a estos cafés.",
            "audio_script_es": "Esta receta está optimizada para tuestes claros. Usamos agua más caliente para extraer toda la acidez brillante y notas frutales que hacen especiales a estos cafés."
        }
    },
    "V60_12g_Extended_Bloom": {
        "title_es": "V60 12g Bloom Extendido",
        "notes_es": "Bloom extra largo para cafés muy frescos con mucho CO2.",
        "preparation_steps_es": [
            "Calienta el agua a 94°C.",
            "Muele 12g de café a molienda media.",
            "Enjuaga el filtro."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Bloom con 30g de agua durante 60 segundos completos.",
                "short_instruction_es": "Bloom 30g • 60 segundos",
                "audio_script_es": "Vierte 30 gramos para el bloom y espera un minuto completo. Este bloom extendido es ideal para café muy fresco con mucho CO2."
            },
            {
                "instruction_es": "Vierte en 2 pulsos de 75g cada uno hasta 180g total.",
                "short_instruction_es": "2 pulsos de 75g • Hasta 180g",
                "audio_script_es": "Vierte en dos pulsos de 75 gramos cada uno. Deja que drene un poco entre cada pulso."
            }
        ],
        "what_to_expect": {
            "description_es": "El bloom extendido de 60 segundos permite que el café muy fresco libere todo su CO2 antes de la extracción principal. Ideal para café recién tostado.",
            "audio_script_es": "Este bloom extra largo es perfecto para café muy fresco. Al esperar un minuto completo, permitimos que todo el CO2 escape antes de la extracción principal."
        }
    },
    "V60_12g_James_Hoffmann_Scaled": {
        "title_es": "V60 12g James Hoffmann Escalado",
        "notes_es": "La técnica de James Hoffmann adaptada para una porción individual más pequeña.",
        "preparation_steps_es": [
            "Calienta el agua a 95°C.",
            "Muele 12g de café a molienda media-fina.",
            "Dobla el filtro por la costura y enjuaga."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Bloom con 24g de agua (2x café), agita suavemente. Espera 45 segundos.",
                "short_instruction_es": "Bloom 24g • Agita • 45 segundos",
                "audio_script_es": "Vierte 24 gramos para el bloom, el doble del peso del café. Agita suavemente el V60 y espera 45 segundos."
            },
            {
                "instruction_es": "Primer vertido principal hasta 120g.",
                "short_instruction_es": "Primer vertido hasta 120g",
                "audio_script_es": "Vierte hasta 120 gramos. Mantén el V60 lleno sin dejarlo drenar completamente."
            },
            {
                "instruction_es": "Segundo vertido hasta 200g, agita suavemente para nivelar.",
                "short_instruction_es": "Segundo vertido hasta 200g • Agita",
                "audio_script_es": "Vierte hasta 200 gramos. Cuando termines, agita suavemente el V60 para nivelar la cama de café."
            }
        ],
        "what_to_expect": {
            "description_es": "La técnica refinada de James Hoffmann adaptada para porciones más pequeñas. Mantiene la misma precisión y consistencia en formato individual.",
            "audio_script_es": "Esta es la técnica de James Hoffmann escalada para una porción individual. Mantiene toda la precisión del método original pero para una sola taza."
        }
    },
    "V60_12g_Mugen_Technique": {
        "title_es": "V60 12g Técnica Mugen",
        "notes_es": "Inspirado en la técnica japonesa Mugen de vertido continuo sin agitación.",
        "preparation_steps_es": [
            "Calienta el agua a 90°C (temperatura baja).",
            "Muele 12g de café a molienda gruesa.",
            "Enjuaga el filtro."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte continuamente 200g de agua en un solo flujo central durante 90 segundos.",
                "short_instruction_es": "Vierte 200g • Centro • 90 segundos",
                "audio_script_es": "Vierte 200 gramos de agua en un flujo continuo directamente en el centro. Esto debería tomar aproximadamente 90 segundos. Sin movimientos circulares, solo el centro."
            },
            {
                "instruction_es": "Espera drenaje completo sin agitar.",
                "short_instruction_es": "Espera drenaje • No agites",
                "audio_script_es": "Espera a que el agua drene completamente. No agites ni muevas el V60. La técnica Mugen evita toda agitación para una taza suave."
            }
        ],
        "what_to_expect": {
            "description_es": "La técnica Mugen evita toda agitación para producir una taza increíblemente suave y delicada. El vertido central crea un flujo natural que extrae sin perturbar.",
            "audio_script_es": "La técnica Mugen japonesa evita toda agitación. Al verter solo en el centro sin movimientos circulares, creamos una extracción suave que produce una taza delicada y dulce."
        }
    },
    "V60_12g_Slow_Drawdown": {
        "title_es": "V60 12g Drenaje Lento",
        "notes_es": "Molienda fina para extender el tiempo de contacto y maximizar la dulzura.",
        "preparation_steps_es": [
            "Calienta el agua a 92°C.",
            "Muele 12g de café a molienda fina.",
            "Enjuaga el filtro."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Bloom con 25g de agua durante 40 segundos.",
                "short_instruction_es": "Bloom 25g • 40 segundos",
                "audio_script_es": "Vierte 25 gramos para el bloom y espera 40 segundos."
            },
            {
                "instruction_es": "Vierte hasta 190g total. Espera drenaje lento (~4 mins total).",
                "short_instruction_es": "Vierte hasta 190g • Drenaje lento 4 mins",
                "audio_script_es": "Vierte hasta 190 gramos. La molienda fina causará un drenaje lento de aproximadamente 4 minutos. Este tiempo extendido maximiza la dulzura."
            }
        ],
        "what_to_expect": {
            "description_es": "La molienda fina extiende el tiempo de contacto para máxima dulzura. El drenaje lento de 4 minutos produce una taza con cuerpo y sabores desarrollados.",
            "audio_script_es": "Usamos molienda fina para extender el tiempo de contacto a 4 minutos. Este drenaje lento maximiza la dulzura y produce una taza con cuerpo completo."
        }
    },
    "V60_14g_121_Recipe": {
        "title_es": "V60 14g Receta 1:2:1",
        "notes_es": "Método estructurado con tres vertidos en proporción 1:2:1 para equilibrio perfecto.",
        "preparation_steps_es": [
            "Calienta el agua a 94°C.",
            "Muele 14g de café a molienda media.",
            "Enjuaga el filtro."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Bloom con 30g de agua durante 30 segundos.",
                "short_instruction_es": "Bloom 30g • 30 segundos",
                "audio_script_es": "Vierte 30 gramos para el bloom, espera 30 segundos. Este es el primer 1 de la proporción 1:2:1."
            },
            {
                "instruction_es": "Primer vertido principal: 60g (total 90g).",
                "short_instruction_es": "Primer vertido 60g • Total 90g",
                "audio_script_es": "Vierte 60 gramos más para alcanzar 90 gramos totales. Este es el 2 de la proporción."
            },
            {
                "instruction_es": "Segundo vertido: 30g (total 120g). Agita para nivelar.",
                "short_instruction_es": "Segundo vertido 30g • Total 120g • Agita",
                "audio_script_es": "Vierte los últimos 30 gramos hasta 120 totales. Agita suavemente para nivelar. Este vertido final es el último 1 de la proporción 1:2:1."
            }
        ],
        "what_to_expect": {
            "description_es": "La estructura 1:2:1 crea una extracción equilibrada con tres fases distintas: inicio suave, cuerpo principal fuerte, y final delicado.",
            "audio_script_es": "La receta 1:2:1 divide el vertido en tres fases proporcionales. Esto crea una extracción equilibrada con inicio suave, cuerpo principal fuerte, y final delicado."
        }
    },
    "V60_14g_Two_Cup_Scaled": {
        "title_es": "V60 14g Dos Tazas Escalado",
        "notes_es": "Versión escalada para preparar dos tazas pequeñas o una grande.",
        "preparation_steps_es": [
            "Calienta el agua a 94°C.",
            "Muele 14g de café a molienda media.",
            "Usa V60 tamaño 02."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Bloom con 35g de agua durante 35 segundos.",
                "short_instruction_es": "Bloom 35g • 35 segundos",
                "audio_script_es": "Vierte 35 gramos para el bloom y espera 35 segundos."
            },
            {
                "instruction_es": "Vierte hasta 140g en círculos.",
                "short_instruction_es": "Vierte hasta 140g • Círculos",
                "audio_script_es": "Vierte en círculos hasta 140 gramos. Mantén el flujo constante."
            },
            {
                "instruction_es": "Vierte hasta 240g total, agita para nivelar.",
                "short_instruction_es": "Vierte hasta 240g • Agita",
                "audio_script_es": "Completa el vertido hasta 240 gramos. Agita suavemente para nivelar la cama y asegurar extracción uniforme."
            }
        ],
        "what_to_expect": {
            "description_es": "Una receta escalada para dos tazas pequeñas o una taza grande. Mantiene el equilibrio y la claridad de una porción individual pero con mayor volumen.",
            "audio_script_es": "Esta receta está escalada para dos tazas pequeñas o una grande. El proceso mantiene el equilibrio y claridad pero produce más café."
        }
    },
    # ========== FRENCH PRESS ==========
    "French_Press_Blue_Bottle_single_serve": {
        "title_es": "Prensa Francesa de Blue Bottle",
        "notes_es": "El método de Blue Bottle enfatiza un reposo largo y presión muy suave para una taza limpia.",
        "preparation_steps_es": [
            "Calienta el agua a 93°C.",
            "Muele 30g de café a molienda gruesa.",
            "Precalienta la prensa francesa."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte 450g de agua uniformemente sobre el café.",
                "short_instruction_es": "Vierte 450g uniformemente",
                "audio_script_es": "Vierte 450 gramos de agua caliente uniformemente sobre el café molido. Asegúrate de mojar todo el café."
            },
            {
                "instruction_es": "Coloca la tapa sin presionar, espera 4 minutos.",
                "short_instruction_es": "Tapa sin presionar • 4 minutos",
                "audio_script_es": "Coloca la tapa encima pero no presiones el émbolo. Espera 4 minutos para la extracción."
            },
            {
                "instruction_es": "Presiona muy lentamente (30-45 segundos).",
                "short_instruction_es": "Presiona muy lento • 30-45s",
                "audio_script_es": "Presiona el émbolo muy lentamente durante 30 a 45 segundos. La presión suave evita agitar los sedimentos."
            }
        ],
        "what_to_expect": {
            "description_es": "El método Blue Bottle produce una taza limpia y con cuerpo completo. La presión extra lenta minimiza los sedimentos en tu taza final.",
            "audio_script_es": "Blue Bottle enfatiza una presión muy lenta para minimizar sedimentos. El resultado es una taza con cuerpo completo pero sorprendentemente limpia."
        }
    },
    "French_Press_Counter_Culture_single_serve": {
        "title_es": "Prensa Francesa de Counter Culture",
        "notes_es": "Método de Counter Culture con agitación inicial para saturación completa.",
        "preparation_steps_es": [
            "Calienta el agua a 94°C.",
            "Muele 28g de café a molienda gruesa.",
            "Precalienta la prensa francesa."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte 400g de agua, revuelve inmediatamente 10 veces.",
                "short_instruction_es": "Vierte 400g • Revuelve 10 veces",
                "audio_script_es": "Vierte 400 gramos de agua caliente y revuelve inmediatamente 10 veces. Esta agitación asegura que todo el café esté saturado."
            },
            {
                "instruction_es": "Coloca la tapa, espera 4 minutos.",
                "short_instruction_es": "Tapa • 4 minutos",
                "audio_script_es": "Coloca la tapa y espera 4 minutos para la extracción."
            },
            {
                "instruction_es": "Presiona lentamente y sirve inmediatamente.",
                "short_instruction_es": "Presiona lento • Sirve inmediato",
                "audio_script_es": "Presiona lentamente y sirve inmediatamente. No dejes el café en la prensa o seguirá extrayendo."
            }
        ],
        "what_to_expect": {
            "description_es": "Counter Culture enfatiza la saturación completa con agitación inicial. Esto produce una extracción más uniforme y sabores desarrollados.",
            "audio_script_es": "El método Counter Culture usa agitación inicial para saturación completa. Esto produce una taza con sabores desarrollados y extracción uniforme."
        }
    },
    "French_Press_Intelligentsia_single_serve": {
        "title_es": "Prensa Francesa de Intelligentsia",
        "notes_es": "El método Intelligentsia con bloom inicial y tiempo de reposo extendido.",
        "preparation_steps_es": [
            "Calienta el agua a 95°C.",
            "Muele 32g de café a molienda gruesa.",
            "Precalienta la prensa francesa."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Bloom con 100g de agua durante 30 segundos.",
                "short_instruction_es": "Bloom 100g • 30 segundos",
                "audio_script_es": "Vierte 100 gramos de agua para un bloom inicial. Espera 30 segundos para desgasificación."
            },
            {
                "instruction_es": "Vierte el resto hasta 450g total, revuelve una vez.",
                "short_instruction_es": "Vierte hasta 450g • Revuelve una vez",
                "audio_script_es": "Vierte el resto del agua hasta 450 gramos y revuelve una vez para mezclar."
            },
            {
                "instruction_es": "Coloca la tapa, espera 5 minutos, presiona lentamente.",
                "short_instruction_es": "Tapa • 5 mins • Presiona lento",
                "audio_script_es": "Coloca la tapa y espera 5 minutos completos. Luego presiona lentamente."
            }
        ],
        "what_to_expect": {
            "description_es": "Intelligentsia incluye un bloom inicial que es inusual para prensa francesa. Esto mejora la extracción y produce sabores más complejos.",
            "audio_script_es": "El método Intelligentsia incluye un bloom inusual para prensa francesa. Este paso extra produce sabores más complejos y desarrollados."
        }
    },
    "French_Press_Ritual_single_serve": {
        "title_es": "Prensa Francesa de Ritual",
        "notes_es": "Método simple y directo de Ritual Coffee Roasters.",
        "preparation_steps_es": [
            "Calienta el agua a 94°C.",
            "Muele 30g de café a molienda gruesa.",
            "Precalienta la prensa."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte 500g de agua sobre el café.",
                "short_instruction_es": "Vierte 500g",
                "audio_script_es": "Vierte 500 gramos de agua caliente directamente sobre el café."
            },
            {
                "instruction_es": "Espera 4 minutos sin tocar.",
                "short_instruction_es": "Espera 4 mins • No toques",
                "audio_script_es": "Espera 4 minutos sin tocar la prensa. Deja que el café extraiga naturalmente."
            },
            {
                "instruction_es": "Presiona suavemente y sirve.",
                "short_instruction_es": "Presiona suave • Sirve",
                "audio_script_es": "Presiona suavemente y sirve inmediatamente."
            }
        ],
        "what_to_expect": {
            "description_es": "El método Ritual es simple y directo. Sin complicaciones, solo café consistente cada vez.",
            "audio_script_es": "Ritual mantiene las cosas simples. Sin pasos complicados, solo un proceso directo que produce café consistente."
        }
    },
    "French_Press_Stumptown_single_serve": {
        "title_es": "Prensa Francesa de Stumptown",
        "notes_es": "Método Stumptown con dos fases de vertido para control de extracción.",
        "preparation_steps_es": [
            "Calienta el agua a 93°C.",
            "Muele 28g de café a molienda gruesa.",
            "Precalienta la prensa francesa."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte 200g de agua, espera 1 minuto.",
                "short_instruction_es": "Vierte 200g • Espera 1 min",
                "audio_script_es": "Vierte 200 gramos de agua y espera 1 minuto. Esta primera fase inicia la extracción."
            },
            {
                "instruction_es": "Vierte 200g más (total 400g), espera 3 minutos adicionales.",
                "short_instruction_es": "Vierte 200g más • Total 400g • 3 mins más",
                "audio_script_es": "Vierte 200 gramos más hasta 400 totales. Espera 3 minutos adicionales para completar la extracción."
            },
            {
                "instruction_es": "Presiona y sirve.",
                "short_instruction_es": "Presiona • Sirve",
                "audio_script_es": "Presiona el émbolo y sirve inmediatamente."
            }
        ],
        "what_to_expect": {
            "description_es": "El método de dos vertidos de Stumptown permite control sobre la extracción. La primera fase extrae acidez, la segunda desarrolla cuerpo.",
            "audio_script_es": "Stumptown usa dos vertidos para control de extracción. La primera fase extrae acidez y notas brillantes, la segunda desarrolla cuerpo y dulzura."
        }
    },
    "French_Press_Tim_Wendelboe_single_serve": {
        "title_es": "Prensa Francesa de Tim Wendelboe",
        "notes_es": "El método refinado de Tim Wendelboe con temperatura alta y tiempo preciso.",
        "preparation_steps_es": [
            "Calienta el agua a 96°C (justo después de hervir).",
            "Muele 28g de café a molienda medio-gruesa.",
            "Precalienta la prensa francesa."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte 450g de agua en movimiento circular.",
                "short_instruction_es": "Vierte 450g • Círculos",
                "audio_script_es": "Vierte 450 gramos de agua caliente en movimiento circular para saturar todo el café uniformemente."
            },
            {
                "instruction_es": "Revuelve suavemente 3 veces.",
                "short_instruction_es": "Revuelve 3 veces",
                "audio_script_es": "Revuelve suavemente 3 veces de adelante hacia atrás para asegurar extracción uniforme."
            },
            {
                "instruction_es": "Coloca la tapa, espera 4 minutos, presiona lentamente.",
                "short_instruction_es": "Tapa • 4 mins • Presiona lento",
                "audio_script_es": "Coloca la tapa sin presionar y espera 4 minutos. Luego presiona lenta y constantemente."
            }
        ],
        "what_to_expect": {
            "description_es": "El método de Tim Wendelboe usa temperatura alta para extracción completa. Produce una taza con cuerpo completo y sabores brillantes.",
            "audio_script_es": "Tim Wendelboe usa temperatura alta para extracción completa. La temperatura de 96 grados extrae todos los sabores brillantes mientras mantiene cuerpo completo."
        }
    },
    "French_Press_Verve_single_serve": {
        "title_es": "Prensa Francesa de Verve",
        "notes_es": "Método Verve con proporción ligeramente más fuerte para café con cuerpo.",
        "preparation_steps_es": [
            "Calienta el agua a 94°C.",
            "Muele 35g de café a molienda gruesa.",
            "Precalienta la prensa francesa."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Vierte 500g de agua uniformemente.",
                "short_instruction_es": "Vierte 500g uniformemente",
                "audio_script_es": "Vierte 500 gramos de agua caliente uniformemente sobre el café."
            },
            {
                "instruction_es": "Rompe la costra con una cuchara después de 4 minutos.",
                "short_instruction_es": "Rompe costra • 4 mins",
                "audio_script_es": "Después de 4 minutos, rompe la costra en la superficie con una cuchara. Esto ayuda a que el molido caiga."
            },
            {
                "instruction_es": "Retira la espuma flotante, espera 2 minutos más, presiona suavemente.",
                "short_instruction_es": "Retira espuma • 2 mins más • Presiona suave",
                "audio_script_es": "Retira la espuma flotante con una cuchara. Espera 2 minutos más, luego presiona muy suavemente."
            }
        ],
        "what_to_expect": {
            "description_es": "El método Verve incluye romper la costra y retirar la espuma. Estos pasos extra producen una taza más limpia con menos sedimentos.",
            "audio_script_es": "Verve incluye pasos extra para limpiar la superficie. Romper la costra y retirar la espuma reduce significativamente los sedimentos en tu taza final."
        }
    },
    # ========== CHEMEX ==========
    "Chemex_Classic_single_serve": {
        "title_es": "Chemex Clásico - Individual",
        "notes_es": "El método clásico de Chemex que produce una taza increíblemente limpia y brillante.",
        "preparation_steps_es": [
            "Calienta el agua a 95°C.",
            "Muele 30g de café a molienda medio-gruesa.",
            "Dobla el filtro Chemex con 3 capas hacia el pico.",
            "Enjuaga el filtro completamente y descarta el agua."
        ],
        "brewing_steps": [
            {
                "instruction_es": "Bloom con 60g de agua durante 45 segundos.",
                "short_instruction_es": "Bloom 60g • 45 segundos",
                "audio_script_es": "Vierte 60 gramos de agua para el bloom. El filtro grueso de Chemex necesita un bloom más largo - espera 45 segundos completos."
            },
            {
                "instruction_es": "Primer vertido: Vierte lentamente hasta 200g en círculos.",
                "short_instruction_es": "Primer vertido hasta 200g • Círculos",
                "audio_script_es": "Vierte lentamente en círculos hasta 200 gramos. Mantén el flujo constante sin acelerar."
            },
            {
                "instruction_es": "Segundo vertido: Vierte hasta 350g, manteniendo el nivel constante.",
                "short_instruction_es": "Segundo vertido hasta 350g",
                "audio_script_es": "Continúa vertiendo hasta 350 gramos. Mantén el nivel del agua constante en el Chemex."
            },
            {
                "instruction_es": "Tercer vertido: Vierte hasta 500g total. Espera drenaje completo (~4-5 mins total).",
                "short_instruction_es": "Tercer vertido hasta 500g • Drenaje 4-5 mins",
                "audio_script_es": "Completa el vertido hasta 500 gramos. Espera el drenaje completo, que debería tomar entre 4 y 5 minutos totales. El filtro grueso de Chemex produce una taza excepcionalmente limpia."
            }
        ],
        "what_to_expect": {
            "description_es": "El Chemex produce una de las tazas más limpias y brillantes posibles. El filtro grueso remueve casi todos los aceites y sedimentos, dejando solo los sabores más puros y claros. Ideal para cafés de origen único con notas frutales o florales.",
            "audio_script_es": "El Chemex produce una taza increíblemente limpia y brillante. El filtro grueso remueve aceites y sedimentos, dejando solo los sabores más puros. Es perfecto para cafés de origen único donde quieres saborear cada nota delicada."
        }
    }
}


def inject_translation(recipe: dict, translation: dict) -> dict:
    """Inject Spanish translations into a recipe."""
    
    # Top-level fields
    if "title_es" in translation:
        recipe["title_es"] = translation["title_es"]
    if "notes_es" in translation:
        recipe["notes_es"] = translation["notes_es"]
    if "preparation_steps_es" in translation:
        recipe["preparation_steps_es"] = translation["preparation_steps_es"]
    
    # Brewing steps
    if "brewing_steps" in translation and "brewing_steps" in recipe:
        for i, step_trans in enumerate(translation["brewing_steps"]):
            if i < len(recipe["brewing_steps"]):
                step = recipe["brewing_steps"][i]
                if "instruction_es" in step_trans:
                    step["instruction_es"] = step_trans["instruction_es"]
                if "short_instruction_es" in step_trans:
                    step["short_instruction_es"] = step_trans["short_instruction_es"]
                if "audio_script_es" in step_trans:
                    step["audio_script_es"] = step_trans["audio_script_es"]
    
    # What to expect
    if "what_to_expect" in translation:
        if "what_to_expect" not in recipe:
            recipe["what_to_expect"] = {"description": ""}
        wte = recipe["what_to_expect"]
        wte_trans = translation["what_to_expect"]
        if "description_es" in wte_trans:
            wte["description_es"] = wte_trans["description_es"]
        if "audio_script_es" in wte_trans:
            wte["audio_script_es"] = wte_trans["audio_script_es"]
    
    return recipe


def get_translation_key(filepath: str) -> str:
    """Extract translation key from filepath."""
    # Get filename without extension
    filename = os.path.basename(filepath).replace(".json", "")
    return filename


def translate_file(filepath: str) -> bool:
    """Translate a single recipe file."""
    key = get_translation_key(filepath)
    
    if key not in TRANSLATIONS:
        print(f"  ⚠️  No translation for: {key}")
        return False
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Handle array wrapper
        is_array = isinstance(data, list)
        recipe = data[0] if is_array else data
        
        # Inject translations
        recipe = inject_translation(recipe, TRANSLATIONS[key])
        
        # Save back
        output_data = [recipe] if is_array else recipe
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(output_data, f, indent=2, ensure_ascii=False)
        
        print(f"  ✅ {key}")
        return True
    except Exception as e:
        print(f"  ❌ Error: {key} - {e}")
        return False


def translate_method(method: str) -> int:
    """Translate all recipes for a method."""
    method_dir = os.path.join(RECIPES_DIR, method)
    
    if not os.path.exists(method_dir):
        print(f"❌ Method not found: {method}")
        return 0
    
    print(f"\n🌍 Translating {method}...")
    
    translated = 0
    for root, dirs, files in os.walk(method_dir):
        for file in files:
            if file.endswith('.json'):
                filepath = os.path.join(root, file)
                if translate_file(filepath):
                    translated += 1
    
    return translated


def main():
    print("=" * 60)
    print("Translate All Recipes to Spanish")
    print("=" * 60)
    
    total = 0
    
    for method in ["AeroPress", "V60", "French_Press", "Chemex"]:
        count = translate_method(method)
        total += count
        print(f"   {method}: {count} recipes translated")
    
    print("\n" + "=" * 60)
    print(f"✅ Total: {total} recipes translated to Spanish")
    print("=" * 60)


if __name__ == "__main__":
    main()

