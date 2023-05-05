using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CamaraOrbital: MonoBehaviour
{
    public GameObject camara;
    public GameObject carpetaTargets;
    private GameObject[] orbitTargets;
    private int currentTarget = 0;
    private int lastTargetIndex;

    // Camera properties
    private float moveSpeed = 4f;
    private float angle = 90;
    private float orbitRadius = 23f;
    private float fov = 100;

    // Start is called before the first frame update
    void Start()
    {
        FillTargets();
        PositionCamera();
    }

    private void FillTargets()
    {
        orbitTargets = new GameObject[carpetaTargets.transform.childCount];
        lastTargetIndex = carpetaTargets.transform.childCount - 1;
        for (int i = 0; i < carpetaTargets.transform.childCount; i++)
        {
            orbitTargets[i] = carpetaTargets.transform.GetChild(i).gameObject;
        }
    }

    private void PositionCamera()
    {
        Vector3 offset = new Vector3(Mathf.Sin(angle), 0.8f, Mathf.Cos(angle)) * orbitRadius;
        camara.transform.position = orbitTargets[currentTarget].transform.position + offset;
        camara.transform.LookAt(orbitTargets[currentTarget].transform);
        camara.GetComponent<Camera>().fieldOfView = fov;
    }

    // Update is called once per frame
    void Update()
    {

        HandleObjectChange();

        HandleLeftAndRightMovement();

        HandleZoom();
    }

    private void HandleObjectChange()
    {
        if ((Input.GetKeyDown(KeyCode.Mouse0)) || (Input.GetKeyDown(KeyCode.Mouse1)) || (Input.GetKeyDown(KeyCode.Mouse2)))
        {
            int previousTarget = currentTarget;

            if (Input.GetKeyDown(KeyCode.Mouse0))
                currentTarget++;
            if (Input.GetKeyDown(KeyCode.Mouse1))
                currentTarget--;

            if (currentTarget < 1)
                currentTarget = lastTargetIndex;
            if (currentTarget > lastTargetIndex)
                currentTarget = 1;

            if (Input.GetKeyDown(KeyCode.Mouse2)) 
                currentTarget = 0;

            if (previousTarget != currentTarget)
            {
                if (previousTarget == 0)
                    fov = 50;
                else if (previousTarget != 0 && currentTarget == 0)
                    fov = 100;
            }

            PositionCamera();
        }
    }

    private void HandleLeftAndRightMovement()
    {
        if ((Input.GetKey(KeyCode.A) || Input.GetKey(KeyCode.D)))
        {
            if (Input.GetKey(KeyCode.A))
            {
                angle = angle + Time.deltaTime * moveSpeed;
            }
            else if (Input.GetKey(KeyCode.D))
            {
                angle = angle - Time.deltaTime * moveSpeed;
            }
            Vector3 offset = new Vector3(Mathf.Sin(angle), 0.8f, Mathf.Cos(angle)) * orbitRadius;
            camara.transform.position = orbitTargets[currentTarget].transform.position + offset;
            camara.transform.LookAt(orbitTargets[currentTarget].transform);
        }
    }

    private void HandleZoom()
    {
        if (Input.GetAxis("Mouse ScrollWheel") > 0f)
        {
            fov--;
            camara.GetComponent<Camera>().fieldOfView = fov;
        }

        if (Input.GetAxis("Mouse ScrollWheel") < 0f)
        {
            fov++;
            camara.GetComponent<Camera>().fieldOfView = fov;
        }
    }
}
