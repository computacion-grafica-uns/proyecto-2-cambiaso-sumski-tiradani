using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ManejadorLuces : MonoBehaviour
{
    public GameObject directionalLight;
    public GameObject pointLight;
    public GameObject spotLight;


    public Color direcColor = new Color(0, 0, 1);
    public Color pointColor = new Color(0, 1, 0);
    public Color spotColor = new Color(1, 0, 0);


    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        // TO - DO

        // Agarrar la pos de los 3 gameobjects y los colores
        // y pasarselo a todos los materiales que existan
        // para que se actualice con la posicion de la luz

        // Hacer lo del input para con 3 teclas desactivar o activar cada luz

            // La spot y point con ponerlas en negro se desactivan

            // La direccional hay que si o si ponerle todo el vector direccion en 0,0,0
            // preguntarle a mati 
    }
}
