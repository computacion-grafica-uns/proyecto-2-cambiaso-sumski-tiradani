using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CamaraPrimeraPersona : MonoBehaviour
{
    public GameObject camara;
    private bool active = false;

    private float moveSpeed = 8f;
    private float sensitivity = 5.0f;
    private float rotationAroundX = 0.0f;
    private float rotationAroundY = 0.0f;

    private void Start()
    {
        PosicionarCamara();
        
        camara.SetActive(false);
    }
    

    private void PosicionarCamara()
    {
        camara.transform.position = new Vector3(0f, 1.8f, 0f);
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.C))
        {
            active = !active;
            camara.SetActive(active);
        }

        if (active)
        {
            // Rotacion de la camara
            float mouseX = Input.GetAxis("Mouse X") * sensitivity;
            float mouseY = Input.GetAxis("Mouse Y") * sensitivity;

            rotationAroundX += mouseY;
            rotationAroundY += mouseX;

            // Bloquea que se pueda mover mas de 90 grados
            rotationAroundX = Mathf.Clamp(rotationAroundX, -90.0f, 90.0f);

            camara.transform.localRotation = Quaternion.Euler(-rotationAroundX, rotationAroundY, 0.0f);

            // Movimiento
            // Vector que mira para adelante
            Vector3 wsDirection = camara.transform.forward.normalized;
            wsDirection = wsDirection * moveSpeed * Time.deltaTime;

            // Vector ortogonal al normal y al de adelante: Vector que a punta hacia un costado de la camara
            Vector3 adDirection = Vector3.Cross(camara.transform.up.normalized, camara.transform.forward.normalized);
            adDirection = adDirection * moveSpeed * Time.deltaTime;
            adDirection.y = 0f;

            if (Input.GetKey(KeyCode.LeftShift)) 
                camara.transform.position -= new Vector3(0, moveSpeed * Time.deltaTime, 0);

            if (Input.GetKey(KeyCode.Space))
                camara.transform.position += new Vector3(0, moveSpeed * Time.deltaTime, 0);

            if (Input.GetKey(KeyCode.W)) 
                camara.transform.position += wsDirection;

            if (Input.GetKey(KeyCode.S))
                camara.transform.position += wsDirection * -1;

            if (Input.GetKey(KeyCode.A))
                camara.transform.position += adDirection * -1;

            if (Input.GetKey(KeyCode.D))
                camara.transform.position += adDirection;

        }
    }
}
