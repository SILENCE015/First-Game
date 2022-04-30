using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pixel2 : PostEffectsBase
{
    public Shader PixelInterval;
    private Material PixelIntervalMat;
    public Material material {
        get {
            PixelIntervalMat = CheckShaderAndCreateMaterial(PixelInterval, PixelIntervalMat);
            return PixelIntervalMat;
        }
    }
    [Range(0, 256)]
    public float pixelSize = 64f;

    void OnRenderImage(RenderTexture src, RenderTexture dest) {
        if(material != null) {
            material.SetFloat("_PixelSize", pixelSize);

            Graphics.Blit(src, dest, material);
        } else {
            Graphics.Blit(src, dest);
        }
    }
}
